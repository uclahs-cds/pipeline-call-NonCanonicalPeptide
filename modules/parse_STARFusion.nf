/* Module to call moPepGen parseSTARFusion */
include { generate_args } from "${moduleDir}/common"

process parse_STARFusion {

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
    output_path = "${sample_name}_${source}_STARFusion.gvf"
    extra_args = generate_args(params, 'parseSTARFusion', ['index_dir', 'source'])
    """
    moPepGen parseSTARFusion \
        --input-path ${input_file} \
        --index-dir ${index_dir} \
        --output-path ${output_path} \
        --source ${source} \
        ${extra_args}
    """
}
