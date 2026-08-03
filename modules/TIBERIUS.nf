#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process TIBERIUS{
    //label 'container'
    publishDir "prediction_output", mode: 'copy'

    //https://github.com/Gaius-Augustus/Tiberius
    container "larsgabriel23/tiberius:latest" //is writen in the config: tiberius_base.config

    input:
    path fasta_file
    //path config
    val model_cfg

    output:
    path "tiberius.gtf", emit: tiberius_results

    script:
    """

    python /opt/Tiberius/tiberius.py \
        --genome ${fasta_file} \
        --model_cfg ${model_cfg} \
        --out "tiberius.gtf"
    """

}