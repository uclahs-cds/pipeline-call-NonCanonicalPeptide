/* module to merge noncanonical peptide fasta files generated by moPepGen. */

process merge_fasta {

    container params.docker_image_moPepGen

    publishDir "${params.final_output_dir}",
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
    output_fasta = "${params.sample_name}_merged_peptides.fasta"
    """
    set -euo pipefail

    moPepGen mergeFasta \\
        --input-path ${input_fasta} \\
        --output-path ${output_fasta}
    """
}
