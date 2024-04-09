/* module for encode fasta */

process encode_FASTA {

    container params.docker_image_moPepGen

    publishDir { mode in ['split', 'filter_split'] ? "${params.final_output_dir}/encode/${mode}" : "${params.final_output_dir}/encode" },
        mode: 'copy',
        pattern: "*.{fasta,fasta.dict}"

    // So each decoy fasta also has a copy of the dict with same name pattern.
    publishDir { mode in ['split', 'filter_split'] ? "${params.final_output_dir}/decoy/${mode}" : "${params.final_output_dir}/decoy" },
        mode: 'copy',
        pattern: "*.fasta.dict",
        saveAs: { "${file(it).getSimpleName()}_decoy.fasta.dict" }

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file input_fasta
        val  mode

    output:
        file output_fasta
        file output_dict
        file ".command.*"

    script:
    output_fasta = "${input_fasta.baseName}_encode.fasta"
    output_dict = "${output_fasta}.dict"
    """
    set -euo pipefail

    moPepGen encodeFasta \\
        --input-path ${input_fasta} \\
        --output-path ${output_fasta}
    """
}
