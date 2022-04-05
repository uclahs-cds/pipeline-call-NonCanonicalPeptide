/* module for summarizing fasta */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'order_source': '--order-source',
    'cleavage_rule': '--cleavage-rule'
]

FLAGS = [
    'invalid_protein_as_noncoding': '--invalid-protein-as-noncoding'
]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process summarize_fasta {

    container params.docker_image_moPepGen

    publishDir params.final_output_dir,
        mode: 'copy',
        pattern: "*_summary.txt"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file gvfs
        file variant_fasta
        file noncoding_peptides
        file index_dir
        val indicator

    output:
        file output_summary
        file ".command.*"

    script:
    output_summary = "${variant_fasta.baseName}_${indicator}_summary.txt"
    noncoding_arg = noncoding_peptides.name == '_NO_FILE' ? '' : "--noncoding-peptides ${noncoding_peptides}"
    extra_args = generate_args(params, 'splitFasta', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen summarizeFasta \
        --gvf ${gvfs} \
        --variant-peptides ${variant_fasta} \
        ${noncoding_arg} \
        ${extra_args} \
        --index-dir ${index_dir} \
        --output-path ${output_summary} \
    """
}
