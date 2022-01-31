/* module to call variant peptides */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'max_variants_per_node': '--max-variants-per-node',
    'cleavage_rule': '--cleavage-rule',
    'miscleavage': '--miscleavage',
    'min_mw': '--min-mw',
    'min_length': '--min-length',
    'max_length': '--max-length'
]

FLAGS = [
    'noncanonical_transcripts': '--noncanonical-transcripts',
    'invalid_protein_as_noncoding': '--invalid-protein-as-noncoding'
]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process call_variant {

    container params.docker_image_moPepGen

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
    output_fasta = "${params.sample_name}-variantPeptides.fasta"
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
