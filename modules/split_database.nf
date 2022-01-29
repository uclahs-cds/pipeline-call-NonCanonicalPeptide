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
        file index_dir

    output:
        file output_dir

    script:
    output_dir = 'split'
    output_prefix = "${output_dir}/${sample_names.join('_')}"
    noncoding_arg = noncoding_fasta.name == '_NO_FILE' ? '' : "--noncoding-peptides ${noncoding_fasta}"
    extra_args = generate_args(params, 'splitDatabase', ['index_dir', 'source'])
    """
    moPepGen splitDatabase \
        --gvf ${gvfs} \
        --variant-peptides ${variant_fasta} \
        ${noncoding_arg} \
        ${extra_args} \
        --index-dir ${index_dir} \
        --output-prefix ${output_prefix} \
    """
}