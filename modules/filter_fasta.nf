/* module for filter fasta */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'skip_lines': '--skip-lines',
    'delimiter ': '--delimiter',
    'tx_id_col': '--tx-id-col',
    'quant_col': '--quant-col',
    'quant_cutoff': '--quant-cutoff'
]

FLAGS = [
    'keep_all_coding': '--keep-all-coding',
    'keep_all_noncoding': '--keep-all-noncoding'
]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process filter_fasta {

    container params.docker_image_moPepGen

    publishDir params.final_output_dir,
        mode: 'copy',
        pattern: "*.fasta"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file input_fasta
        file exprs_table
        file index_dir
        val indicator

    output:
        file output_fasta
        file ".command.*"

    script:
    output_fasta = "${input_fasta.baseName}_${indicator}_filtered.fasta"
    extra_args = generate_args(params['filterFasta'], indicator, ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen filterFasta \\
        --input-path ${input_fasta} \\
        --output-path ${output_fasta} \\
        --exprs-table ${exprs_table} \\
        --index-dir ${index_dir} \\
        ${extra_args}
    """
}
