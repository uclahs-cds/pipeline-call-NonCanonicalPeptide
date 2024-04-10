/* module for summarizing fasta */
include { generate_args } from "${moduleDir}/common"

ARGS = [
    'order_source': '--order-source',
    'cleavage_rule': '--cleavage-rule'
]

FLAGS = [
    'invalid_protein_as_noncoding': '--invalid-protein-as-noncoding',
    'ignore_missing_source': '--ignore-missing-source'
]

def get_args_and_flags() {
    return [ARGS, FLAGS]
}

process summarize_FASTA {

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
        file variant_peptide
        file novel_orf_peptide
        file alt_translation_peptide
        file index_dir
        val tag

    output:
        file output_summary
        file ".command.*"

    script:
    output_summary = tag == 'NO_TAG' ? "${variant_peptide.baseName}_summary.txt" : "${variant_peptide.baseName}_${tag}_summary.txt"
    noncoding_arg = novel_orf_peptide.name == params._DEFAULT_NOVEL_ORF_PEPTIDES ? '' : "--noncoding-peptides ${novel_orf_peptide}"
    alt_translation_arg = alt_translation_peptide.name == params._DEFAULT_ALT_TRANSLATION_PEPTIDES ? '' : "--alt-translation-peptides ${alt_translation_peptide}"
    extra_args = generate_args(params, 'summarizeFasta', ARGS, FLAGS)
    """
    set -euo pipefail

    moPepGen summarizeFasta \
        --gvf ${gvfs} \
        --variant-peptides ${variant_peptide} \
        ${noncoding_arg} \
        ${alt_translation_arg} \
        ${extra_args} \
        --index-dir ${index_dir} \
        --output-path ${output_summary} \
    """
}
