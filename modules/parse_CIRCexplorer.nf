/* Module to call moPepGen parseCIRCexplorer */
include { generate_args } from "${moduleDir}/common"

process parse_CIRCexplorer {

    container params.docker_image_moPepGen

    publishDir params.output_dir, mode: 'copy'

    input:
        tuple(
            val(sample_name),
            val(source),
            file(input_file)
        )
        file(genome_index)

    output:
        file output_gvf

    script:
    output_prefix = "${sample_name}_${source}_CIRCexplorer"
    output_gvf = "${output_prefix}.gvf"
    arg_list = ['min_read_number', 'min_fpb_circ', 'min_circ_score']
    extra_args = generate_args(params, arg_list)
    if (params.containsKey('circexplorer3') and params.circexplorer3 == true) {
        extra_args += " --circexplorer3"
    }
    """
    moPepGen parseCIRCexplorer \
        --vep-txt ${input_file} \
        --index-dir ${genome_index} \
        --output-prefix ${output_prefix} \
        --source ${source} \
        --circexplorer3 ${params.circexplorer3} \
        --min_read_number ${params.min_read_number} \
        ${extra_args}
    """
}
