#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process WORKFLOW{
    publishDir "Fragpipe_output/workflow", mode: 'copy'

    container "docker://fcyucn/fragpipe:latest"

    input:
    path template_workflow
    path decoy_results

    output:
    path 'custom_workflow.workflow', emit: workflow

    script:
    """
    cp  ${template_workflow} custom_workflow.workflow

    echo "database.db-path=\$(pwd)/${decoy_results}" >> custom_workflow.workflow 
    cat custom_workflow.workflow
    """

}