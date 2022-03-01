/* module for resolving filename conflict */

process resolve_filename_conflict {
    input:
        file input_file

    output:
        file output_file

    script:
    output_file = "${input_file.baseName}_${task.index}.${input_file.extension}"
    """
    ln -s ${input_file} ${output_file}
    """
}
