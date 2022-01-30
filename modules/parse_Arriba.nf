/* Module to call moPepGen parserFusionCatcher */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'min_split_read1': '--min-split-read1',
    'min_split_read2': '--min-split-read2',
    'min_confidence': '--min-confidence'
]

FLAGS = [:]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process parse_Arriba {

    container params.docker_image_moPepGen

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':', '/')}/",
        mode: 'copy',
        pattern: "*.gvf",
        enabled: params.save_intermediate_files

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(sample_name),
            val(source),
            file(input_file)
        )
        file index_dir

    output:
        file output_path optional true
        file ".command.*"

    script:
    output_path = "${sample_name}_${source}_Arriba.gvf"
    extra_args = generate_args(params, 'parseArriba', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen parseArriba \
        --input-path ${input_file} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        --source ${source} \
        ${extra_args}
    """
}
