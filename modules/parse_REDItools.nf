/* Module to call moPepGen parseREDItools */
include { generate_args } from "${moduleDir}/common"

process parse_REDItools {

    container params.docker_image_moPepGen

    publishDir params.output_dir, mode: 'copy'

    input:
        tuple(
            val(sample_name),
            val(source),
            file(input_file)
        )
        file genome_index

    output:
        file output_gvf

    script:
    output_prefix = "${sample_name}_${source}_VEP"
    output_gvf = "${output_prefix}.gvf"
    arg_list = ['transcript_id_column']
    extra_args = generate_args(params, arg_list)
    """
    moPepGen parseREDItools \
        --reditools-table ${input_file} \
        --index-dir ${genome_index} \
        --output-prefix ${output_prefix} \
        --source ${source} \
        ${extra_args}
    """
}
