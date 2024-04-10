/* Main entrypoint for call-NoncanonicalPeptides */
nextflow.enable.dsl = 2

include { print_prelogue } from './modules/common'
include { parse_SourceVariant_workflow } from './modules/parse_SourceVariant_workflow'
include { call_VariantPeptide } from './modules/call_VariantPeptide'
include { summarize_FASTA } from './modules/summarize_FASTA'
include { resolve_conflictFileName } from './modules/resolve_conflictFileName'
include { process_NonCanonicalDatabase_merge_workflow } from './modules/process_NonCanonicalDatabase_merge_workflow'
include { process_NonCanonicalDatabase_split_workflow } from './modules/process_NonCanonicalDatabase_split_workflow'
include { process_NonCanonicalDatabase_plain_workflow } from './modules/process_NonCanonicalDatabase_plain_workflow'

print_prelogue()

workflow {
    if (params.entrypoint == 'parser') {
        parse_SourceVariant_workflow()
        ch_gvf_files = parse_SourceVariant_workflow.out.collect()
        call_VariantPeptide(ch_gvf_files, file(params.index_dir))
        ch_variant_fasta = call_VariantPeptide.out[0]

    } else {
        ich = Channel.fromPath(params.input_csv).splitCsv(header:true).map { file(it.path) }
        resolve_conflictFileName(ich)
        ch_gvf_files = resolve_conflictFileName.out.collect()

        if (params.entrypoint == 'fasta') {
            ch_variant_fasta = Channel.fromPath(params.variant_peptide)
        } else {
            call_VariantPeptide(ch_gvf_files, file(params.index_dir))
            ch_variant_fasta = call_VariantPeptide.out[0]
        }
    }

    summarize_FASTA(
        ch_gvf_files,
        ch_variant_fasta,
        file(params.novel_orf_peptide),
        file(params.alt_translation_peptide),
        file(params.index_dir),
        'NO_TAG'
    )

    if ('plain' in params.database_processing_modes) {
        process_NonCanonicalDatabase_plain_workflow(ch_gvf_files, ch_variant_fasta)
    }

    if ('merge' in params.database_processing_modes) {
        process_NonCanonicalDatabase_merge_workflow(ch_gvf_files, ch_variant_fasta)
    }

    if ('split' in params.database_processing_modes) {
        process_NonCanonicalDatabase_split_workflow(ch_gvf_files, ch_variant_fasta)
    }
}
