/* Module to call moPepGen parseCIRCexplorer */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'min_read_number': '--min-read-number',
    'min_fpb_circ': '--min-fpb-circ',
    'min_circ_score': '--min-circ-score',
    'intron_start_range': '--intron-start-range',
    'intron_end_range': '--intron-end-range'
]

FLAGS = [
    'circexplorer3': '--circexplorer3'
]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process parse_CIRCexplorer {

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
        file(index_dir)

    output:
        file output_path optional true
        file ".command.*"

    script:
    output_path = "${params.sample_name}_${source}_CIRCexplorer.gvf"
    extra_args = generate_args(params, 'parseCIRCexplorer', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen parseCIRCexplorer \
        --input-path ${input_file} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        --source ${source} \
        ${extra_args}
    """
}
