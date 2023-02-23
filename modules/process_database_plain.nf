include { split_fasta } from './split_fasta'
include { filter_fasta } from './filter_fasta'
include { summarize_fasta } from './summarize_fasta'
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
        encode_decoy_unfiltered(variant_fasta, 'plain')
    }

    if (params.filter_fasta) {
        // filterFasta Variant
        filter_fasta(
            variant_fasta,
            file(params.exprs_table),
            file(params.index_dir),
            'variant_peptides'
        )
        variant_fasta_filtered = filter_fasta.out[0]
        summarize_fasta(
            gvf_files,
            variant_fasta_filtered,
            '_NO_FILE',
            file(params.index_dir),
            'variant_only'
        )
        encode_decoy_filtered(variant_fasta_filtered, 'plain')
    }
}
