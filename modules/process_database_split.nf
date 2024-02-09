include {
    split_fasta as split_fasta_unfiltered
    split_fasta as split_fasta_filtered
 } from './split_fasta'
include {
   filter_fasta as filter_fasta_variant
   filter_fasta as filter_fasta_noncoding
   filter_fasta as filter_fasta_alt_translation
} from './filter_fasta'
include { summarize_fasta } from './summarize_fasta'
include {
    encode_decoy as encode_decoy_unfiltered
    encode_decoy as encode_decoy_filtered
} from './workflow_encode_decoy'

/**
* Workflow to process database FASTA file(s) directly outputted by callVariant without merging or splitting.
*/

workflow process_database_split {
    take:
    gvf_files
    variant_fasta

    main:

    // Split, encode and decoy the unfiltered FASTA
    if (params.process_unfiltered_fasta) {
        split_fasta_unfiltered(
            gvf_files,
            variant_fasta,
            file(params.noncoding_peptides),
            file(params.alt_translation_peptides),
            file(params.index_dir),
            false
        )
        encode_decoy_unfiltered(split_fasta_unfiltered.out[1].flatten(), 'split')
    }

    if (params.filter_fasta) {
        // filterFasta Noncoding
        if (params.noncoding_peptides != params._DEFAULT_NONCODING_PEPTIDES) {
            filter_fasta_noncoding (
                file(params.noncoding_peptides),
                file(params.exprs_table),
                file(params.index_dir),
                'noncoding_peptides'
            )
            noncoding_peptides_filtered = filter_fasta_noncoding.out[0]
        } else {
            noncoding_peptides_filtered = file(params.noncoding_peptides)
        }

        // filterFasta alt translation
        if (params.alt_translation_peptides != params._DEFAULT_ALT_TRANSLATION_PEPTIDES) {
            filter_fasta_alt_translation (
                file(params.alt_translation_peptides),
                file(params.exprs_table),
                file(params.index_dir),
                'alt_translation_peptides'
            )
            alt_translation_peptides_filtered = filter_fasta_alt_translation.out[0]
        } else {
            alt_translation_peptides_filtered = file(params.alt_translation_peptides)
        }

        // filterFasta Variant
        filter_fasta_variant(
            variant_fasta,
            file(params.exprs_table),
            file(params.index_dir),
            'variant_peptides'
        )
        variant_fasta_filtered = filter_fasta_variant.out[0]

        // Summarized the filtered fasta files
        summarize_fasta(
            gvf_files,
            variant_fasta_filtered,
            noncoding_peptides_filtered,
            alt_translation_peptides_filtered,
            file(params.index_dir),
            'NO_TAG'
        )

        // splitFasta
        split_fasta_filtered(
            gvf_files,
            variant_fasta_filtered,
            noncoding_peptides_filtered,
            alt_translation_peptides_filtered,
            file(params.index_dir),
            true
        )
        split_fasta_file = split_fasta_filtered.out[1].flatten()

        encode_decoy_filtered(split_fasta_file, 'filter_split')
    }
}
