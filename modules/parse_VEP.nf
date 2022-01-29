/* Module to call moPepGen parseVEP */
include { generate_args } from "${moduleDir}/common"

process parse_VEP {

    container params.docker_image_moPepGen

    publishDir params.output_dir, mode: 'copy'

    input:
        tuple(
            val(sample_name),
            val(source),
            file(input_file)
        )
        file index_dir

    output:
        file output_path optional true

    script:
    output_path = "${sample_name}_${source}_VEP.gvf"
    args = generate_args(params, 'parseVEP', ['source', 'index_dir'])
    """
    moPepGen parseVEP \
        --input-path ${input_file} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        --source ${source} \
        ${args}
    """
}
