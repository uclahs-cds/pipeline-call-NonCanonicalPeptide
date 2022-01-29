/* Module to call moPepGen parseRMATS */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'min_ijc': '--min-ijc',
    'min_sjc': '--min-sjc'
]

FLAGS = [:]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process parse_rMATS {

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
            file(se),
            file(a5ss),
            file(a3ss),
            file(mxe),
            file(ri)
        )
        file index_dir

    output:
        file output_path optional true
        file ".command.*"

    script:
    output_path = "${sample_name}_${source}_rMATs.gvf"
    input_args = ''
    input_args += se.name == '_NO_FILE' ? " --se ${se}" : ''
    input_args += a5ss.name == '_NO_FILE' ? " --a5ss ${a5ss}" : ''
    input_args += a3ss.name == '_NO_FILE' ? " --a3ss ${a3ss}" : ''
    input_args += mxe.name == '_NO_FILE' ? " --mxe ${mxe}" : ''
    input_args += ri.name == '_NO_FILE' ? " --ri ${ri}" : ''
    extra_args = generate_args(params, 'parseRMATS', ARGS, FLAGS)
    """
    moPepGen parseRMATS \
        ${input_args} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        ${extra_args} \
        --source ${source}
    """
}
