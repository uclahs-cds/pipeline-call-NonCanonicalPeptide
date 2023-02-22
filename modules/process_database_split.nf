include {
    split_fasta as split_fasta_unfiltered
    split_fasta as split_fasta_filtered
 } from './split_fasta'
include {
   filter_fasta as filter_fasta_variant
   filter_fasta as filter_fasta_noncoding
} from './filter_fasta'
include { summarize_fasta as summarize_fasta_split } from './summarize_fasta'
include {
    encode_decoy as encode_decoy_unfiltered
    encode_decoy as encode_decoy_filtered
} from './workflow_encode_decoy'

/**
* Workflow to process database FASTA file(s) without the variant and noncoding peptides merged.
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
            file(params.index_dir),
            params.filter_fasta_variant
        )
        encode_decoy_unfiltered(split_fasta_unfiltered.out[1].flatten(), 'split')
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
            summarize_fasta_split(gvf_files, variant_fasta_filtered, noncoding_peptides_filtered, file(params.index_dir))
        } else {
            variant_fasta_filtered = variant_fasta
        }

        // splitFasta
        split_fasta_filtered(
            gvf_files,
            variant_fasta_filtered,
            noncoding_peptides_filtered,
            file(params.index_dir),
            params.filter_fasta_variant
        )
        split_fasta_file = split_fasta_filtered.out[1].flatten()

        encode_decoy_filtered(split_fasta_file, 'filter_split')
    }
}
