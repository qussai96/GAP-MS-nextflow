#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process DECOY {
    stageInMode 'copy'

    publishDir "${projectDir}/Fragpipe_output/database", mode: 'copy'

    container 'sznistvan/philo:latest'
    //--cleanev: does not allwow to use the host environment variables
    //--bind: allows to bind the current working directory and the fasta file to the container
    //containerOptions "--cleanenv --bind ${projectDir}" //!!!! delate scratch later -> for now scratch is not bind to the container 

    input:
    val ready
    path fasta_file
    val add_contaminants
    val decoy_tag

    output:
    path "decoy_fasta_results.fasta", emit: decoy_results

    script:
    template 'decoy.sh'


}