/* module for splitting database */
include { generate_args } from "${moduleDir}/common"

process split_database {

    container params.docker_image_moPepGen

    publishDir params.output_dir, mode: 'copy'

    input:
        val sample_names
        file gvfs
        file variant_fasta
        file noncoding_fasta
        file genome_index

    output:
        file output_dir

    script:
    output_dir = 'split'
    output_prefix = "${output_dir}/${sample_names.join('_')}"
    noncoding_arg = noncoding_fasta.name == '_NO_FILE' ? '' : "--noncoding-peptides ${noncoding_fasta}"
    arg_list = ['order_source', 'group_source', 'max_source_groups', 'additional_split']
    extra_args = generate_args(params, arg_list)
    """
    moPepGen splitDatabase \
        --variant-gvf ${gvfs}\
        --variant-peptides ${variant_fasta} \
        ${noncoding_arg} \
        ${extra_args} \
        --index-dir ${genome_index} \
        --output-prefix ${output_prefix}
    """
}