/* module for generating decoy fasta */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'method': '--method',
    'non_shuffle_pattern ': '--non-shuffle-pattern',
    'shuffle_max_attempts': '--shuffle-max-attempts',
    'seed': '--seed',
    'order': '--order',
    'decoy_string': '--decoy-string',
    'decoy_string_position': '--decoy-string-position',
    'keep_peptide_nterm': '--keep-peptide-ntnerm',
    'keep_peptide_cterm': '--keep-peptide-cterm'
]

FLAGS = [:]

process decoy_fasta {

    container params.docker_image_moPepGen

    publishDir "${params.final_output_dir}/decoy",
        mode: 'copy',
        pattern: "*.fasta"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file input_fasta

    output:
        file output_fasta
        file ".command.*"

    script:
    output_fasta = "${input_fasta.baseName}_decoy.fasta"
    extra_args = generate_args(params, 'decoyFasta', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen decoyFasta \\
        --input-path ${input_fasta} \\
        --output-path ${output_fasta} \\
        ${extra_args}
    """
}
