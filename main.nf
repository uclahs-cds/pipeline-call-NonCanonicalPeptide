/* Main entrypoint for call-NoncanonicalPeptides */
nextflow.enable.dsl = 2

include { print_prelogue } from './modules/common'
include { call_parsers } from './modules/call_parsers'
include { call_variant } from './modules/call_variant'
include { summarize_fasta as summarize_fasta_pre } from './modules/summarize_fasta'
include { resolve_filename_conflict } from './modules/resolve_filename_conflict'
include { process_database_merge } from './modules/process_database_merge'
include { process_database_nomerge } from './modules/process_database_nomerge'

print_prelogue()

workflow {
    if (params.entrypoint == 'parser') {
        call_parsers()
        gvf_files = call_parsers.out.collect()
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

    summarize_fasta_pre(
        gvf_files,
        variant_fasta,
        file(params.noncoding_peptides),
        file(params.index_dir)
    )

    if (params.merge_variant_noncoding in ['yes', 'both']) {
        process_database_merge(gvf_files, variant_fasta)
    }

    if (params.merge_variant_noncoding in ['no', 'both']) {
        process_database_nomerge(gvf_files, variant_fasta)
    }
}
