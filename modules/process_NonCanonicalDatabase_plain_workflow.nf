include { split_FASTA } from './split_FASTA'
include { filter_FASTA } from './filter_FASTA'
include { summarize_FASTA } from './summarize_FASTA'
include {
    encodeDecoy_FASTA_workflow as encodeDecoy_FASTA_unfiltered
    encodeDecoy_FASTA_workflow as encodeDecoy_FASTA_filtered
} from './encodeDecoy_FASTA_workflow'

/**
* Workflow to process database FASTA file(s) without the variant and noncoding peptides merged.
*/

workflow process_NonCanonicalDatabase_plain_workflow {
    take:
    gvf_files
    variant_fasta

    main:
    // Unfiltered fasta
    if (params.process_unfiltered_fasta) {
        encodeDecoy_FASTA_unfiltered(variant_fasta, 'plain')
    }

    if (params.enable_filter_fasta) {
        // filterFasta Variant
        filter_FASTA(
            variant_fasta,
            file(params.exprs_table),
            file(params.index_dir),
            'variant_peptides'
        )
        ch_variant_peptides_filtered = filter_FASTA.out[0]
        summarize_FASTA(
            gvf_files,
            ch_variant_peptides_filtered,
            file(params._DEFAULT_NOVEL_ORF_PEPTIDES),
            file(params._DEFAULT_ALT_TRANSLATION_PEPTIDES),
            file(params.index_dir),
            'variant_only'
        )
        encodeDecoy_FASTA_filtered(ch_variant_peptides_filtered, 'plain')
    }
}
