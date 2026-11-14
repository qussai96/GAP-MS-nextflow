#!/usr/bin/env nextflow

process TRANSDECODER{
    stageInMode 'copy'

    publishDir "${projectDir}/VARUS_output/dataset", mode: 'copy'

    //container 'docker://biocontainers/transdecoder:v5.0.1-2-deb_cv1'
    container '/home/students/s.blaszczak/work/singularity/transdecoder-5.0.1-procps.sif'

    input:
    path input_file

    output:
    path "varus_faa_ready.faa", emit: varus_faa

    script: 
    """
    TransDecoder.LongOrfs -t ${input_file} 
    TransDecoder.Predict -t ${input_file} 

    mv ${input_file}.transdecoder.pep varus_faa_ready.faa
    """

}