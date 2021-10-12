/* module to call variant peptides */
include { generate_args } from "${moduleDir}/common"

process call_variant {

    container params.docker_image_moPepGen

    publishDir params.output_dir, mode: 'copy'

    input:
        val sample_names
        file gvf_files
        file genome_index

    output:
        file output_fasta

    script:
    output_fasta = "${sample_names.join('_')}-variantPeptides.fasta"
    arg_list = ['miscleavage', 'min_mw', 'min_length', 'max_length']
    extra_args = generate_args(params, arg_list)
    """
    moPepGen callVariant \
        --input-variant ${gvf_files} \
        --output-fasta ${output_fasta} \
        --index-dir ${genome_index} \
        ${extra_args}
    """
}
