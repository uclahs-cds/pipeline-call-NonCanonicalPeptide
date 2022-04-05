/* Main entrypoint for call-NoncanonicalPeptides */
nextflow.enable.dsl = 2

include { print_prelogue } from './modules/common'
include { parse_VEP } from './modules/parse_VEP'
include { parse_STARFusion } from './modules/parse_STARFusion'
include { parse_FusionCatcher } from './modules/parse_FusionCatcher'
include { parse_Arriba } from './modules/parse_Arriba'
include { parse_REDItools } from './modules/parse_REDItools'
include { parse_CIRCexplorer } from './modules/parse_CIRCexplorer'
include { parse_rMATS } from './modules/parse_rMATS'
include { call_variant } from './modules/call_variant'
include { split_fasta } from './modules/split_fasta'
include { filter_fasta } from './modules/filter_fasta'
include { encode_fasta } from './modules/encode_fasta'
include { decoy_fasta } from './modules/decoy_fasta'
include { summarize_fasta as summarize_fasta_pre; summarize_fasta as summarize_fasta_post } from './modules/summarize_fasta'
include { resolve_filename_conflict } from './modules/resolve_filename_conflict'

print_prelogue()

workflow {
   if (params.entrypoint == 'parser') {
      ich = Channel.fromPath(params.input_csv).splitCsv(header:true)
         .map{ [it.software, it.alt_splice_type, it.source, file(it.path)] }

      ich_branched = ich.branch {
            vep: it[0] == 'VEP'
               return [it[2], it[3]]
            star_fusion: it[0] == 'STAR-Fusion'
               return [it[2], it[3]]
            fusion_catcher: it[0] == 'FusionCatcher'
               return [it[2], it[3]]
            arriba: it[0] == 'Arriba'
               return [it[2], it[3]]
            rmats: it[0] == 'rMATs'
               return it
            circexplorer: it[0] == 'CIRCexplorer'
               return [it[2], it[3]]
            reditools: it[0] == 'REDItools'
               return [it[2], it[3]]
            other: true
               throw new Exception("Variant called by software ${it[1]} is not supported.")
               return
         }

      ich_rmats = ich_branched.rmats.map {[it[0], it]}.groupTuple(by:0).map {
         def source = it[1][0][2]
         def se = '_NO_FILE'
         def a5ss = '_NO_FILE'
         def a3ss = '_NO_FILE'
         def mxe = '_NO_FILE'
         def ri = '_NO_FILE'
         for (x in it[1]) {
            switch( x[1] ) {
               case 'SE':
                  se = x[3];
                  break
               case 'A5SS':
                  a5ss = x[3]
                  break
               case 'A3SS':
                  a3ss = x[3]
                  break
               case 'MXE':
                  mxe = x[3]
                  break
               case 'RI':
                  ri = x[3]
                  break
               default:
                  throw new Exception("rMATs type ${x[1]} unknown")
            }
         }
         return [source, se, a5ss, a3ss, mxe, ri]
      }

      parse_VEP(ich_branched.vep, file(params.index_dir))
      parse_STARFusion(ich_branched.star_fusion, file(params.index_dir))
      parse_FusionCatcher(ich_branched.fusion_catcher, file(params.index_dir))
      parse_Arriba(ich_branched.arriba, file(params.index_dir))
      parse_REDItools(ich_branched.reditools, file(params.index_dir))
      parse_CIRCexplorer(ich_branched.circexplorer, file(params.index_dir))
      parse_rMATS(ich_rmats, file(params.index_dir))

      gvf_files = Channel.from().mix(
         parse_VEP.out[0],
         parse_STARFusion.out[0],
         parse_FusionCatcher.out[0],
         parse_Arriba.out[0],
         parse_REDItools.out[0],
         parse_CIRCexplorer.out[0],
         parse_rMATS.out[0]
      ).collect()
      call_variant(gvf_files, file(params.index_dir))
      variant_fasta = call_variant.out[0]

   } else {
      ich = Channel.fromPath(params.input_csv).splitCsv(header:true).map { file(it.path) }
      resolve_filename_conflict(ich)
      gvf_files = resolve_filename_conflict.out.collect()

      if (params.entrypoint == 'fasta') {
         variant_fasta = Channel.fromPath(params.variant_fasta)
      } else {
         call_variant(gvf_files, file(params.index_dir))
         variant_fasta = call_variant.out[0]
      }
   }

   summarize_fasta_pre(gvf_files, variant_fasta, file(params.noncoding_peptides), file(params.index_dir))

   if (params.filter_fasta) {
      filter_fasta(
         variant_fasta,
         file(params.exprs_table),
         file(params.index_dir)
      )
      variant_fasta_filtered = filter_fasta.out[0]
      summarize_fasta_post(gvf_files, variant_fasta_filtered, file(params.noncoding_peptides), file(params.index_dir))
   } else {
      variant_fasta_filtered = variant_fasta
   }

   if (params.split_fasta) {
      split_fasta(
         gvf_files,
         variant_fasta_filtered,
         file(params.noncoding_peptides),
         file(params.index_dir)
      )
      splitted_fasta_file = split_fasta.out[1].flatten()
   } else {
      splitted_fasta_file = variant_fasta_filtered
   }

   if (params.encode_fasta) {
      encode_fasta(splitted_fasta_file)
      encoded_fasta_file = encode_fasta.out[0]
   } else {
      encoded_fasta_file = splitted_fasta_file
   }

   if (params.decoy_fasta) {
      decoy_fasta(encoded_fasta_file)
   }
}
