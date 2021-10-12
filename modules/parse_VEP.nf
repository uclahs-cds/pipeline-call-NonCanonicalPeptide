/* Module to call moPepGen parseVEP */

process parse_VEP {

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
    """
    moPepGen parseVEP \
        --vep-txt ${input_file} \
        --index-dir ${genome_index} \
        --output-prefix ${output_prefix} \
        --source ${source}
    """
}
