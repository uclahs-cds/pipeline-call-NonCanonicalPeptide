import groovy.io.FileType

/*
    Generate command line args. Argument from `arg_list` will be added to the returned value if it
    is specified in the `par`
    input:
        par: Can be either a config object or a groovy map.
        arg_list: A list of values.

    output:
        A string of command line args.
*/
def generate_args(Map par, String namespace, Map args, Map flags) {
    def res = ''
    if(!(par.containsKey(namespace))) return res
    for (it in par[namespace].keySet()) {
        if(it in args.keySet()) {
            res += " ${args[it]} ${par[namespace][it]}"
        } else if (it in flags.keySet() && par[namespace][it] == true) {
            res += " ${args[it]}"
        }
    }
    return res
}

/* Log prelogue message */
def print_prelogue() {
    options = ''
    for (namespace in params.keySet()) {
        if (namespace.contains('-')) continue
        if (params[namespace] in Map) {
            options += '\n' + ' ' * 12 + '- ' + namespace + ':'
            data = [:]
            for (key in params[namespace].keySet()) {
                data[key] = params[namespace][key]
            }
            max_len = (data.keySet() as ArrayList).collect{it.size()}.max()
            for (key in data.keySet()) {
                options += '\n' + ' ' * 16 + key.padRight(max_len, ' ') + ": ${data[key]}"
            }
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
            sample_name : ${params.sample_name}
            input_csv   : ${params.input_csv}
            index_dir   : ${params.index_dir}

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
