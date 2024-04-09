include { merge_FASTA } from './merge_FASTA'
include { filter_FASTA as filter_FASTA_merged } from './filter_FASTA'
include {
    summarize_FASTA as summarize_FASTA_merge_unfiltered
    summarize_FASTA as summarize_FASTA_merge_filtered
} from './summarize_FASTA'
include {
    encodeDecoy_FASTA_workflow as encodeDecoy_FASTA_unfiltered
    encodeDecoy_FASTA_workflow as encodeDecoy_FASTA_filtered
} from './encodeDecoy_FASTA_workflow'

/**
* Workflow to process the database FASTA file(s) with variant and noncoding peptides merged.
*/

workflow process_NonCanonicalDatabase_merge_workflow {
    take:
    gvf_files
    variant_fasta

    main:
    // mergeFasta
    if (params.noncoding_peptides == params._DEFAULT_NONCODING_PEPTIDES) {
        ich_noncoding_peptides = Channel.fromList()
    } else {
        ich_noncoding_peptides = Channel.fromPath(params.noncoding_peptides)
    }

    if (params.alt_translation_peptides == params._DEFAULT_ALT_TRANSLATION_PEPTIDES) {
        ich_alt_translation_peptides = Channel.fromList()
    } else {
        ich_alt_translation_peptides = Channel.fromPath(params.alt_translation_peptides)
    }

    ich_fastas_to_be_merged = variant_fasta
        .mix(ich_noncoding_peptides)
        .mix(ich_alt_translation_peptides)
        .collect()

    merge_FASTA(ich_fastas_to_be_merged)

    if (params.process_unfiltered_fasta) {
        summarize_FASTA_merge_unfiltered(
            gvf_files,
            merge_FASTA.out[0],
            file(params._DEFAULT_NONCODING_PEPTIDES),
            file(params._DEFAULT_ALT_TRANSLATION_PEPTIDES),
            file(params.index_dir),
            'NO_TAG'
        )
        encodeDecoy_FASTA_unfiltered(merge_FASTA.out[0], 'merge')
    }

    // fitlerFasta
    if (params.filter_fasta) {
        filter_FASTA_merged(
            merge_FASTA.out[0],
            file(params.exprs_table),
            file(params.index_dir),
            'merged_peptides'
        )
        ch_merged_fasta_filtered = filter_FASTA_merged.out[0]
        summarize_FASTA_merge_filtered(
            gvf_files,
            ch_merged_fasta_filtered,
            file(params._DEFAULT_NONCODING_PEPTIDES),
            file(params._DEFAULT_ALT_TRANSLATION_PEPTIDES),
            file(params.index_dir),
            'NO_TAG'
        )
        encodeDecoy_FASTA_filtered(ch_merged_fasta_filtered, 'merge_filter')
    }
}
