/* Module to call moPepGen parseRMATS */

process parse_rMATS {

    container params.docker_image_moPepGen

    publishDir params.output_dir, mode: 'copy'

    input:
        tuple(
            val(sample_name),
            val(source),
            file(se),
            file(a5ss),
            file(a3ss),
            file(mxe),
            file(ri)
        )
        file genome_index

    output:
        file output_gvf

    script:
    output_prefix = "${sample_name}_${source}_rMATS"
    output_gvf = "${output_prefix}.gvf"
    input_args = ''
    input_args += se.name == '_NO_FILE' ? " --skipped-exon ${se}" : ''
    input_args += a5ss.name == '_NO_FILE' ? " --alternative-5-splicing ${a5ss}" : ''
    input_args += a3ss.name == '_NO_FILE' ? " --alternative-3-splicing ${a3ss}" : ''
    input_args += mxe.name == '_NO_FILE' ? " --mutually-exclusive-exons ${mxe}" : ''
    input_args += ri.name == '_NO_FILE' ? " --retained-intron ${ri}" : ''
    """
    moPepGen parseRMATS \
        ${input_args} \
        --index-dir ${genome_index} \
        --output-prefix ${output_prefix} \
        --source ${source}
    """
}
