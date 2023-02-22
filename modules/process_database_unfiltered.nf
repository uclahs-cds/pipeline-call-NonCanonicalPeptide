include { split_fasta } from './split_fasta'
include { filter_fasta } from './filter_fasta'
include { encode_fasta } from './encode_fasta'
include { decoy_fasta } from './decoy_fasta'

/**
* Workflow to process database FASTA file(s) without the variant and noncoding peptides merged.
*/

workflow process_database_nomerge {
    take:
    gvf_files
    variant_fasta

    main:

    // Split, encode and decoy the unfiltered FASTA
    split_fasta(
        gvf_files,
        variant_fasta_filtered,
        noncoding_peptides_filtered,
        file(params.index_dir),
        params.filter_fasta_variant
    )
    encode_fasta(split_fasta.out[1].flatten())
    decoy_fasta(encode_fasta.out[0])
}
