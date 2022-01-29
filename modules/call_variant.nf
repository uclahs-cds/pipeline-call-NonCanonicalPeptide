/* module to call variant peptides */
include { generate_args } from "${moduleDir}/common"

process call_variant {

    container params.docker_image_moPepGen

    publishDir params.output_dir, mode: 'copy'

    input:
        val sample_names
        file gvf_files
        file index_dir

    output:
        file output_fasta optional true

    script:
    output_fasta = "${sample_names.join('_')}-variantPeptides.fasta"
    extra_args = generate_args(params, 'callVariant', ['index_dir'])
    """
    moPepGen callVariant \
        --input-path ${gvf_files} \
        --output-path ${output_fasta} \
        --index-dir ${index_dir} \
        ${extra_args} \
        --threads ${task.cpus}
    """
}
