include { merge_fasta } from './merge_fasta'
include { filter_fasta as filter_fasta_merged } from './filter_fasta'
include {
    summarize_fasta as summarize_fasta_merge
    summarize_fasta as summarize_fasta_merge_filtered
} from './summarize_fasta'
include {
    encode_decoy as encode_decoy_unfiltered
    encode_decoy as encode_decoy_filtered
} from './workflow_encode_decoy'

/**
* Workflow to process the database FASTA file(s) with variant and noncoding peptides merged.
*/

workflow process_database_merge {
    take:
    gvf_files
    variant_fasta

    main:
    // mergeFasta
    if (params.noncoding_peptides == '_NO_FILE') {
        ich_noncoding_peptides = Channel.fromPath(params.noncoding_peptides)
    } else {
        ich_noncoding_peptides = Channel.fromList()    
    }
    merge_fasta(variant_fasta.mix(ich_noncoding_peptides).collect())

    if (params.process_unfiltered_fasta) {
        encode_decoy_unfiltered(merge_fasta.out[0], 'merge')
        summarize_fasta_merge(
            gvf_files,
            merge_fasta.out[0],
            file('_NO_FILE'),
            file(params.index_dir)
        )
    }

    // fitlerFasta
    if (params.filter_fasta) {
        filter_fasta_merged(
            merge_fasta.out[0],
            file(params.exprs_table),
            file(params.index_dir),
            'merged_peptides'
        )
        merged_fasta_filtered = filter_fasta_merged.out[0]
        summarize_fasta_merge_filtered(
            gvf_files,
            merged_fasta_filtered,
            file('_NO_FILE'),
            file(params.index_dir)
        )
        encode_decoy_filtered(merged_fasta_filtered, 'merge_filter')
    }
}
