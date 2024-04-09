include { encode_FASTA } from './encode_FASTA'
include { decoy_FASTA } from './decoy_FASTA'

workflow encodeDecoy_FASTA_workflow {
    take:
    fasta_file
    mode

    main:
    // encodeFasta
    if (params.enable_encode_fasta) {
        encode_FASTA(fasta_file, mode)
        ch_encoded_fasta_file = encode_FASTA.out[0]
    } else {
        ch_encoded_fasta_file = fasta_file
    }

    // decoyFasta
    if (params.enable_decoy_fasta) {
        decoy_FASTA(ch_encoded_fasta_file, mode)
    }
}
