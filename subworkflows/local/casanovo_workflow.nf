#!/usr/bin/env nextflow

include { THERMORAWFILEPARSER } from '../../modules/nf-core/thermorawfileparser/main.nf'
include { CASANOVO } from '../../modules/local/CASANOVO.nf'
include { MZTAB_TO_TSV } from '../../modules/local/MZTAB_TO_TSV.nf'

workflow casanovo_workflow{

    take:
    raw_ms_files

    main:

    if (params.mzTab_casanovo){
        casanovo_results_ch = Channel.fromPath(params.mzTab_casanovo, type: 'dir', checkIfExists: true)

    }else{
        raw_ms_ch = Channel.fromPath("${raw_ms_files}/*.raw", checkIfExists: true)
        .map { file -> tuple([id: file.baseName], file) }

        THERMORAWFILEPARSER(raw_ms_ch)
        CASANOVO(THERMORAWFILEPARSER.out.spectra)

        casanovo_results_ch = CASANOVO.out.casanovo_results.collect()
    }

    MZTAB_TO_TSV(casanovo_results_ch)
    
    emit:
        casanovo_results = MZTAB_TO_TSV.out.casanovo_tsv 
}