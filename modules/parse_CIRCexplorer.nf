/* Module to call moPepGen parseCIRCexplorer */
include { generate_args } from "${moduleDir}/common"

process parse_CIRCexplorer {

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
        file(index_dir)

    output:
        file output_path optional true
        file ".command.*"

    script:
    output_path = "${sample_name}_${source}_CIRCexplorer.gvf"
    extra_args = generate_args(params, 'parseCIRCexplorer', ['index_dir', 'source'])
    """
    moPepGen parseCIRCexplorer \
        --input-path ${input_file} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        --source ${source} \
        --circexplorer3 ${params.circexplorer3} \
        --min_read_number ${params.min_read_number} \
        ${extra_args}
    """
}
