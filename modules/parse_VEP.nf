/* Module to call moPepGen parseVEP */
include { generate_args } from "${moduleDir}/common"

ARGS = [:]

FLAGS = [:]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process parse_VEP {

    container params.docker_image_moPepGen

    publishDir params.final_output_dir,
        mode: 'copy',
        pattern: "*.gvf"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(source),
            file(input_file)
        )
        file index_dir

    output:
        file output_path optional true
        file ".command.*"

    script:
    output_path = "${params.sample_id}_${source}_VEP.gvf"
    args = generate_args(params, 'parseVEP', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen parseVEP \
        --input-path ${input_file} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        --source ${source} \
        ${args}
    """
}
