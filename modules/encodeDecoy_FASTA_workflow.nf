include { encode_fasta } from './encode_fasta'
include { decoy_FASTA } from './decoy_FASTA'

workflow encodeDecoy_FASTA_workflow {
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
        decoy_FASTA(encoded_fasta_file, mode)
    }
}
