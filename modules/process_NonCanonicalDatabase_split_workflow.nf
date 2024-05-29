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
} from './encodeDecoy_FASTA_workflow'

/**
* Workflow to process database FASTA file(s) directly outputted by callVariant without merging or splitting.
*/

workflow process_NonCanonicalDatabase_split_workflow {
    take:
    gvf_files
    variant_peptide

    main:

    // Split, encode and decoy the unfiltered FASTA
    if (params.process_unfiltered_fasta) {
        split_FASTA_unfiltered(
            gvf_files,
            variant_peptide,
            params.novel_orf_peptide,
            params.alt_translation_peptide,
            params.index_dir,
            false
        )
        encodeDecoy_FASTA_workflow_unfiltered(split_FASTA_unfiltered.out[1].flatten(), 'split')
    }

    if (params.enable_filter_fasta) {
        // filterFasta Noncoding
        if (params.novel_orf_peptide != params._DEFAULT_NOVEL_ORF_PEPTIDES) {
            filter_FASTA_novelORF (
                params.novel_orf_peptide,
                params.exprs_table,
                params.index_dir,
                'novel_orf_peptide'
            )
            ch_novelORF_peptides_filtered = filter_FASTA_novelORF.out[0]
        } else {
            ch_novelORF_peptides_filtered = file(params.novel_orf_peptide)
        }

        // filterFasta alt translation
        if (params.alt_translation_peptide != params._DEFAULT_ALT_TRANSLATION_PEPTIDES) {
            filter_FASTA_altTrans (
                params.alt_translation_peptide,
                params.exprs_table,
                params.index_dir,
                'alt_translation_peptide'
            )
            ch_altTrans_peptides_filtered = filter_FASTA_altTrans.out[0]
        } else {
            ch_altTrans_peptides_filtered = file(params.alt_translation_peptide)
        }

        // filterFasta Variant
        filter_FASTA_variant(
            variant_peptide,
            params.exprs_table,
            params.index_dir,
            'variant_peptide'
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
            params.index_dir,
            true
        )
        ch_split_filtered_fasta = split_FASTA_filtered.out[1].flatten()

        encodeDecoy_FASTA_workflow_filtered(ch_split_filtered_fasta, 'filter_split')
    }
}
