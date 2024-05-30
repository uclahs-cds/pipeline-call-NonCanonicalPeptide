/* Module to call moPepGen parseVEP */
include { generate_args } from "${moduleDir}/common"

process resolve_conflictVEPFileName {
    publishDir params.final_output_dir,
        mode: 'copy',
        pattern: "*.gvf"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(identifier),
            path(input_file)
        )

    output:
        tuple(
            val(identifier),
            path(output_file)
        )
        path ".command.*"

    script:
    def filename = input_file.name
    def tokens = filename.tokenize('.')
    def basename
    def suffix
    if (tokens[-1] == 'gz') {
        basename = tokens[0..-3].join('.')
        suffix = tokens[-2..-1].join('.')
    } else {
        basename = tokens[0..-2].join('.')
        suffix = tokens[-1]
    }
    output_file = "${basename}_${identifier}_${task.index}.${suffix}"
    """
    set -euo pipefail

    ln -s ${input_file.toRealPath()} $output_file
    """
}
