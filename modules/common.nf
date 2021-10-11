/*
    Generate command line args. Argument from `arg_list` will be added to the returned value if it
    is specified in the `par`
    input:
        par: Can be either a config object or a groovy map.
        arg_list: A list of values.

    output:
        A string of command line args.
*/
def generate_args(par, arg_list) {
    def args = ''
    for (it in arg_list) {
        if (par.containsKey(it)) {
            args += " --${it.replace('_', '-')} ${par[it]}"
        }
    }
    return args
}

/* Log prelogue message */
def print_prelogue() {
    option_args = [
        'min_est_j', 'transcript_id_column', 'min_read_number', 'min_fpb_circ',
        'min_circ_score', 'miscleavage', 'min_mw', 'min_length', 'max_length'
    ]
    max_len = option_args.collect{it.size()}.max()
    options = ''
    for (arg in option_args) {
        if (params.containsKey(arg)) {
            options += '\n' + ' ' * 12 + arg.padRight(max_len, ' ') + ": ${params[arg]}"
        }
    }
    // Log info here
    log.info """\
        =====================================================
        C A L L   N O N C A N O N I C A L   P E P E T I D E S
        =====================================================
        Boutros Lab

        Current Configuration:
        - pipeline:
            name: ${workflow.manifest.name}
            version: ${workflow.manifest.version}

        - input:
            input_csv   : ${params.input_csv}
            genome_index: ${params.genome_index}

        - output:
            output_dir: ${params.output_dir}

        - options: ${options}

        Tools Used:
            moPepGen: ${params.docker_image_moPepGen}

        ------------------------------------
        Starting workflow...
        ------------------------------------
        """
        .stripIndent()
}
