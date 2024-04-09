/* module for splitting fasta */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'order_source': '--order-source',
    'group_source': '--group-source',
    'max_source_groups': '--max-source-groups',
    'additional_split': '--additional-split'
]

FLAGS = [
    'invalid_protein_as_noncoding': '--invalid-protein-as-noncoding'
]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process split_FASTA {

    container params.docker_image_moPepGen

    publishDir params.final_output_dir,
        mode: 'copy',
        pattern: "split"

    publishDir params.final_output_dir,
        mode: 'copy',
        pattern: "filter_split"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file gvfs
        file variant_fasta
        file noncoding_peptides
        file alt_translation_peptides
        file index_dir
        val filtered

    output:
        file output_dir
        file "${output_dir}/*.fasta"
        file ".command.*"

    script:
    output_dir = filtered == true ? 'filter_split' : 'split'
    output_prefix = "${output_dir}/${params.sample_name}_split"
    noncoding_arg = noncoding_peptides.name == params._DEFAULT_NONCODING_PEPTIDES ? '' : "--noncoding-peptides ${noncoding_peptides}"
    alt_translation_arg = alt_translation_peptides.name == params._DEFAULT_ALT_TRANSLATION_PEPTIDES ? '' : "--alt-translation-peptides ${alt_translation_peptides}"
    extra_args = generate_args(params, 'splitFasta', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen splitFasta \
        --gvf ${gvfs} \
        --variant-peptides ${variant_fasta} \
        ${noncoding_arg} \
        ${alt_translation_arg} \
        ${extra_args} \
        --index-dir ${index_dir} \
        --output-prefix ${output_prefix} \
    """
}
