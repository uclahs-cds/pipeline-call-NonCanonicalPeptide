include { merge_fasta } from './merge_fasta'
include { filter_fasta as filter_fasta_merged } from './filter_fasta'
include {
    summarize_fasta as summarize_fasta_merge
    summarize_fasta as summarize_fasta_merge_filtered
} from './summarize_fasta'
include {
    encode_decoy as encode_decoy_unfiltered
    encode_decoy as encode_decoy_filtered
} from './workflow_encode_decoy'

/**
* Workflow to process the database FASTA file(s) with variant and noncoding peptides merged.
*/

workflow process_database_merge {
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

    merge_fasta(ich_fastas_to_be_merged)

    if (params.process_unfiltered_fasta) {
        summarize_fasta_merge(
            gvf_files,
            merge_fasta.out[0],
            file(params._DEFAULT_NONCODING_PEPTIDES),
            file(params._DEFAULT_ALT_TRANSLATION_PEPTIDES),
            file(params.index_dir),
            'NO_TAG'
        )
        encode_decoy_unfiltered(merge_fasta.out[0], 'merge')
    }

    // fitlerFasta
    if (params.filter_fasta) {
        filter_fasta_merged(
            merge_fasta.out[0],
            file(params.exprs_table),
            file(params.index_dir),
            'merged_peptides'
        )
        merged_fasta_filtered = filter_fasta_merged.out[0]
        summarize_fasta_merge_filtered(
            gvf_files,
            merged_fasta_filtered,
            file(params._DEFAULT_NONCODING_PEPTIDES),
            file(parmas._DEFAULT_ALT_TRANSLATION_PEPTIDES),
            file(params.index_dir),
            'NO_TAG'
        )
        encode_decoy_filtered(merged_fasta_filtered, 'merge_filter')
    }
}
