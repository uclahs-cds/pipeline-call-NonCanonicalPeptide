include { encode_fasta } from './encode_fasta'
include { decoy_fasta } from './decoy_fasta'

workflow encode_decoy {
    take:
    fasta_file
    mode

    main:
    // encodeFasta
    if (params.encode_fasta) {
        encode_fasta(fasta_file, mode)
        encoded_fasta_file = encode_fasta.out[0]
    } else {
        encoded_fasta_file = fasta_file
    }

    // decoyFasta
    if (params.decoy_fasta) {
        decoy_fasta(encoded_fasta_file, mode)
    }
}
