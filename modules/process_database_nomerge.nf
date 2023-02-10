include { split_fasta } from './split_fasta'
include {
   filter_fasta as filter_fasta_variant;
   filter_fasta as filter_fasta_noncoding;
} from './filter_fasta'
include { encode_fasta } from './encode_fasta'
include { decoy_fasta } from './decoy_fasta'
include { summarize_fasta as summarize_fasta_nomerge } from './summarize_fasta'

/**
* Workflow to process database FASTA file(s) without the variant and noncoding peptides merged.
*/

workflow process_database_nomerge {
    take:
    gvf_files
    variant_fasta

    main:
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

    // splitFasta
    if (params.split_fasta) {
        split_fasta(
            gvf_files,
            variant_fasta_filtered,
            noncoding_peptides_filtered,
            file(params.index_dir),
            params.filter_fasta_variant
        )
        split_fasta_file = split_fasta.out[1].flatten()
    } else {
        split_fasta_file = variant_fasta_filtered
    }

    // encodeFasta
    if (params.encode_fasta) {
        encode_fasta(split_fasta_file)
        encoded_fasta_file = encode_fasta.out[0]
    } else {
        encoded_fasta_file = split_fasta_file
    }

    // decoyFasta
    if (params.decoy_fasta) {
        decoy_fasta(encoded_fasta_file)
    }
}
