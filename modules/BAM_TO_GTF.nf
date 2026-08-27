#!/usr/bin/env nextflow

process BAM_TO_GTF{
    stageInMode 'copy'

    publishDir "${projectDir}/VARUS_output/dataset", mode: 'copy'

    container 'docker://nanozoo/stringtie:3.0.0--1c320c8'

    input:
    path varus_results 
   

    output:
    path "varus.gtf", emit: varus_gtf

    script: 
    """
    stringtie -o varus.gtf ${varus_results}
    """
}