include { parse_VEP } from './parse_VEP'
include { parse_STARFusion } from './parse_STARFusion'
include { parse_FusionCatcher } from './parse_FusionCatcher'
include { parse_Arriba } from './parse_Arriba'
include { parse_REDItools } from './parse_REDItools'
include { parse_CIRCexplorer } from './parse_CIRCexplorer'
include { parse_rMATS } from './parse_rMATS'

/**
* Workflow to call all moPepGen parsers
*/

workflow call_parsers {
    main:
    ich = Channel.fromPath(params.input_csv).splitCsv(header:true)
        .map{ [it.software, it.alt_splice_type, it.source, file(it.path)] }

    ich_branched = ich.branch {
        vep: it[0] == 'VEP'
            return [it[2], it[3]]
        star_fusion: it[0] == 'STAR-Fusion'
            return [it[2], it[3]]
        fusion_catcher: it[0] == 'FusionCatcher'
            return [it[2], it[3]]
        arriba: it[0] == 'Arriba'
            return [it[2], it[3]]
        rmats: it[0] == 'rMATS'
            return it
        circexplorer: it[0] == 'CIRCexplorer'
            return [it[2], it[3]]
        reditools: it[0] == 'REDItools'
            return [it[2], it[3]]
        other: true
            throw new Exception("Variant called by software ${it[1]} is not supported.")
            return
        }

    ich_rmats = ich_branched.rmats.map {[it[0], it]}.groupTuple(by:0).map {
        def source = it[1][0][2]
        def se = '_NO_FILE'
        def a5ss = '_NO_FILE'
        def a3ss = '_NO_FILE'
        def mxe = '_NO_FILE'
        def ri = '_NO_FILE'
        for (x in it[1]) {
        switch( x[1] ) {
            case 'SE':
                se = x[3];
                break
            case 'A5SS':
                a5ss = x[3]
                break
            case 'A3SS':
                a3ss = x[3]
                break
            case 'MXE':
                mxe = x[3]
                break
            case 'RI':
                ri = x[3]
                break
            default:
                throw new Exception("rMATS type ${x[1]} unknown")
        }
        }
        return [source, se, a5ss, a3ss, mxe, ri]
    }

    parse_VEP(ich_branched.vep, file(params.index_dir))
    parse_STARFusion(ich_branched.star_fusion, file(params.index_dir))
    parse_FusionCatcher(ich_branched.fusion_catcher, file(params.index_dir))
    parse_Arriba(ich_branched.arriba, file(params.index_dir))
    parse_REDItools(ich_branched.reditools, file(params.index_dir))
    parse_CIRCexplorer(ich_branched.circexplorer, file(params.index_dir))
    parse_rMATS(ich_rmats, file(params.index_dir))

    gvf_files = Channel.from().mix(
        parse_VEP.out[0],
        parse_STARFusion.out[0],
        parse_FusionCatcher.out[0],
        parse_Arriba.out[0],
        parse_REDItools.out[0],
        parse_CIRCexplorer.out[0],
        parse_rMATS.out[0]
    )

    emit:
    gvf_files
}
