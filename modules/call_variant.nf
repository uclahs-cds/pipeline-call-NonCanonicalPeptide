/* module to call variant peptides */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'max_variants_per_node': '--max-variants-per-node',
    'max_adjacent_as_mnv': '--max-adjacent-as-mnv',
    'additional_variants_per_misc': '--additional-variants-per-misc',
    'min_nodes_to_collapse': '--min-nodes-to-collapse',
    'naa_to_collapse': '--naa-to-collapse',
    'verbose_level': '--verbose-level',
    'cleavage_rule': '--cleavage-rule',
    'miscleavage': '--miscleavage',
    'min_mw': '--min-mw',
    'min_length': '--min-length',
    'max_length': '--max-length',
    'timeout_seconds': '--timeout-seconds'
]

FLAGS = [
    'noncanonical_transcripts': '--noncanonical-transcripts',
    'invalid_protein_as_noncoding': '--invalid-protein-as-noncoding',
    'selenocysteine_termination': '--selenocysteine-termination',
    'w2f_reassignment': '--w2f-reassignment'
]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process call_variant {

    container params.docker_image_moPepGen

    containerOptions "--shm-size=10.24gb"

    publishDir params.final_output_dir,
        mode: 'copy',
        pattern: "*.fasta"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file gvf_files
        file index_dir

    output:
        file output_fasta optional true
        file ".command.*"

    script:
    output_fasta = "${params.sample_name}_variant_peptides.fasta"
    extra_args = generate_args(params, 'callVariant', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen callVariant \
        --input-path ${gvf_files} \
        --output-path ${output_fasta} \
        --index-dir ${index_dir} \
        ${extra_args} \
        --threads ${task.cpus}
    """
}
