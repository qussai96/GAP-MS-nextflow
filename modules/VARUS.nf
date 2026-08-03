#!/usr/bin/env nextflow

process VARUS{

    publishDir "VARUS_output/", mode: 'copy'

    container "varus.sif"

    input:
    path fasta_file
    val genus
    val species


    output:
    path "VARUS.bam", emit: varus_results 


    script:
    """
    varus runlist "${genus} ${species}" --outdir .

    varus index ${fasta_file} --outdir genome_idx/

    varus run "${genus} ${species}" ${fasta_file} \
        --runlist Runlist.tsv \
        --index genome_idx/hisatidx \
        --outdir .

    """
}