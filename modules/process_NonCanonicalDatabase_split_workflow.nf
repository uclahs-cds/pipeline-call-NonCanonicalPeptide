include {
    split_FASTA as split_FASTA_unfiltered
    split_FASTA as split_FASTA_filtered
 } from './split_FASTA'
include {
   filter_FASTA as filter_FASTA_variant
   filter_FASTA as filter_FASTA_novelORF
   filter_FASTA as filter_FASTA_altTrans
} from './filter_FASTA'
include { summarize_FASTA } from './summarize_FASTA'
include {
    encodeDecoy_FASTA_workflow as encodeDecoy_FASTA_workflow_unfiltered
    encodeDecoy_FASTA_workflow as encodeDecoy_FASTA_workflow_filtered
} from './workflow_encode_decoy'

/**
* Workflow to process database FASTA file(s) directly outputted by callVariant without merging or splitting.
*/

workflow process_NonCanonicalDatabase_split_workflow {
    take:
    gvf_files
    variant_fasta

    main:

    // Split, encode and decoy the unfiltered FASTA
    if (params.process_unfiltered_fasta) {
        split_FASTA_unfiltered(
            gvf_files,
            variant_fasta,
            file(params.noncoding_peptides),
            file(params.alt_translation_peptides),
            file(params.index_dir),
            false
        )
        encodeDecoy_FASTA_workflow_unfiltered(split_FASTA_unfiltered.out[1].flatten(), 'split')
    }

    if (params.filter_fasta) {
        // filterFasta Noncoding
        if (params.noncoding_peptides != params._DEFAULT_NONCODING_PEPTIDES) {
            filter_FASTA_novelORF (
                file(params.noncoding_peptides),
                file(params.exprs_table),
                file(params.index_dir),
                'noncoding_peptides'
            )
            ch_novelORF_peptides_filtered = filter_FASTA_novelORF.out[0]
        } else {
            ch_novelORF_peptides_filtered = file(params.noncoding_peptides)
        }

        // filterFasta alt translation
        if (params.alt_translation_peptides != params._DEFAULT_ALT_TRANSLATION_PEPTIDES) {
            filter_FASTA_altTrans (
                file(params.alt_translation_peptides),
                file(params.exprs_table),
                file(params.index_dir),
                'alt_translation_peptides'
            )
            ch_altTrans_peptides_filtered = filter_FASTA_altTrans.out[0]
        } else {
            ch_altTrans_peptides_filtered = file(params.alt_translation_peptides)
        }

        // filterFasta Variant
        filter_FASTA_variant(
            variant_fasta,
            file(params.exprs_table),
            file(params.index_dir),
            'variant_peptides'
        )
        ch_variant_peptides_filtered = filter_FASTA_variant.out[0]

        // Summarized the filtered fasta files
        summarize_FASTA(
            gvf_files,
            ch_variant_peptides_filtered,
            ch_novelORF_peptides_filtered,
            ch_altTrans_peptides_filtered,
            file(params.index_dir),
            'NO_TAG'
        )

        // splitFasta
        split_FASTA_filtered(
            gvf_files,
            ch_variant_peptides_filtered,
            ch_novelORF_peptides_filtered,
            ch_altTrans_peptides_filtered,
            file(params.index_dir),
            true
        )
        ch_split_filtered_fasta = split_FASTA_filtered.out[1].flatten()

        encodeDecoy_FASTA_workflow_filtered(ch_split_filtered_fasta, 'filter_split')
    }
}
