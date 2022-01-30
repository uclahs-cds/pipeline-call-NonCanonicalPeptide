/* Module to call moPepGen parseREDItools */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'transcript_id_column': '--transcript-id-column',
    'min_coverage_alt': '--min-coverage-alt',
    'min_frequency_alt': '--min-frequency-alt',
    'min_coverage_dna': '--min-coverage-dna'
]

FLAGS = [:]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process parse_REDItools {

    container params.docker_image_moPepGen

    beforeScript 'set -euo pipefail'

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
    output_path = "${sample_name}_${source}_REDItools.gvf"
    extra_args = generate_args(params, 'parseREDItools', ARGS, FLAGS)
    """
    moPepGen parseREDItools \
        --input-path ${input_file} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        --source ${source} \
        ${extra_args}
    """
}
