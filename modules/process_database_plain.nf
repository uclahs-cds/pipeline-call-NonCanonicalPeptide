include { split_fasta } from './split_fasta'
include { filter_fasta } from './filter_fasta'
include {
    encode_decoy as encode_decoy_unfiltered
    encode_decoy as encode_decoy_filtered
} from './workflow_encode_decoy'

/**
* Workflow to process database FASTA file(s) without the variant and noncoding peptides merged.
*/

workflow process_database_plain {
    take:
    gvf_files
    variant_fasta

    main:
    // Unfiltered fasta
    if (params.process_unfiltered_fasta) {
        encode_decoy_unfiltered(variant_fasta)
    }

    if (params.filter_fasta_noncoding || params.filter_fasta_variant) {
        // filterFasta Noncoding
        if (params.filter_fasta_noncoding) {
            filter_fasta_noncoding (
                file(params.noncoding_peptides),
                file(params.exprs_table),
                file(params.index_dir),
                'noncoding_peptides'
            )
            noncoding_peptides_filtered = filter_fasta_noncoding.out[0]
        } else {
            noncoding_peptides_filtered = Channel.fromPath(params.noncoding_peptides)
        }

        // filterFasta Variant
        if (params.filter_fasta_variant) {
            filter_fasta_variant(
                variant_fasta,
                file(params.exprs_table),
                file(params.index_dir),
                'variant_peptides'
            )
            variant_fasta_filtered = filter_fasta_variant.out[0]
            summarize_fasta_nomerge(gvf_files, variant_fasta_filtered, noncoding_peptides_filtered, file(params.index_dir))
        } else {
            variant_fasta_filtered = variant_fasta
        }

        encode_decoy_filtered(variant_fasta_filtered)
    }
}
