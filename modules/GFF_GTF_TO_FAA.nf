#!/usr/bin/env nextflow

process GFF_GTF_TO_FAA{

    publishDir "prediction_output", mode: 'copy'

    container 'docker://dceoy/gffread:latest'

    input:
    path gff3_or_gtf_file //gff3 or gtf 
    path fasta_file // orginal fasta file given to Helixer/Tiberius

    output:
    path "prediction.faa", emit: prediction_fasta

    script: 
    """
    gffread ${gff3_or_gtf_file} -g ${fasta_file} -y prediction.faa
    """
}