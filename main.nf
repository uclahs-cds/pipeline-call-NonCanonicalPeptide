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
include { split_database } from './modules/split_database'

print_prelogue()

workflow {
   ich = Channel.fromPath(params.input_csv).splitCsv(header:true)
      .map{ [it.sample_name, it.software, it.alt_splice_type, it.source, file(it.path)] }

   sample_names = ich.map { it[0] }.distinct().collect()

   ich_branched = ich.branch {
         vep: it[1] == 'VEP'
            return [it[0], it[3], it[4]]
         star_fusion: it[1] == 'STAR-Fusion'
            return [it[0], it[3], it[4]]
         fusion_catcher: it[1] == 'FusionCatcher'
            return [it[0], it[3], it[4]]
         arriba: it[1] == 'Arriba'
            return [it[0], it[3], it[4]]
         rmats: it[1] == 'rMATs'
            return it
         circexplorer: it[1] == 'CIRCexplorer'
            return [it[0], it[3], it[4]]
         reditools: it[1] == 'REDItools'
            return [it[0], it[3], it[4]]
         other: true
            throw new Exception("Variant called by software ${it[1]} is not supported.")
            return
      }

   ich_rmats = ich_branched.rmats.map {[it[0], it]}.groupTuple(by:0).map {
      def sample = it[0]
      def source = it[1][0][3]
      def se = '_NO_FILE'
      def a5ss = '_NO_FILE'
      def a3ss = '_NO_FILE'
      def mxe = '_NO_FILE'
      def ri = '_NO_FILE'
      for (x in it[1]) {
         switch( x[2] ) {
            case 'SE':
               se = x[4];
               break
            case 'A5SS':
               a5ss = x[4]
               break
            case 'A3SS':
               a3ss = x[4]
               break
            case 'MXE':
               mxe = x[4]
               break
            case 'RI':
               ri = x[4]
               break
            default:
               throw new Exception("rMATs type ${x[2]} unknown")
         }
      }
      return [sample, source, se, a5ss, a3ss, mxe, ri]
   }

   parse_VEP(ich_branched.vep, file(params.index_dir))

   parse_STARFusion(ich_branched.star_fusion, file(params.index_dir))

   parse_FusionCatcher(ich_branched.fusion_catcher, file(params.index_dir))

   parse_Arriba(ich_branched.arriba, file(params.index_dir))

   parse_REDItools(ich_branched.reditools, file(params.index_dir))

   parse_CIRCexplorer(ich_branched.circexplorer, file(params.index_dir))

   parse_rMATS(ich_rmats, file(params.index_dir))

   parser_output = Channel.from().mix(
      parse_VEP.out[0],
      parse_STARFusion.out[0],
      parse_REDItools.out[0],
      parse_CIRCexplorer.out[0],
      parse_rMATS.out[0]
   ).collect()

   call_variant(sample_names, parser_output, file(params.index_dir))

   if (params.split_database) {
      split_database(
         sample_names,
         parser_output,
         call_variant.out[0],
         file(params.noncoding_fasta),
         file(params.index_dir)
      )
   }
}
