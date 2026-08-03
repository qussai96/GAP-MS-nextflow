#!/usr/bin/env nextflow

process GAPMS{

    publishDir "GAPMS_output/", mode: 'copy'

    container "oras://docker.io/qussaiab96/gapms:latest"

    input:
    path peptides // -p
    path gtf // -g
    path proteins // -f
    path fasta_file //-a
    path bam //-b

    output:
    path "results/**"


    script:
    def output_dir  = (params.output && params.output != "null") ? params.output : "results"
    def output_flag = "-o ${output_dir}"

    //def gtf_flag      = gtf ? "-g ${gtf}" : ""
    def fasta_flag    = (fasta_file && fasta_file.name != 'NO_FILE') ? "-a ${fasta_file}" : ""
    def bam_flag      = (bam && bam.name != 'NO_FILE') ? "-b ${bam}"       : ""
    def proteins_flag = (proteins && proteins.name != 'NO_FILE') ? "-f ${proteins}" : "" 
    def mapping_flag  = params.mapping ? "-m ${params.mapping}" : "" 
    def scores_flag  = params.scores ? "-s ${params.scores}" : "" 
    def reference_gtf_flag  = params.reference_gtf ? "-rg ${params.reference_gtf}" : "" 
    def reference_fasta_flag  = params.reference_fasta ? "-rf ${params.reference_fasta}" : "" 
    def iterative_flag  = params.iterative ? "-i ${params.iterative}" : "" 
    
    """
    # Extracts just the needed peptide sequence column 1 this way skipping the header 
    awk -F'\\t' 'NR>1 {print \$1}' ${peptides} > clean_peptides.tsv

    gapms -p clean_peptides.tsv -g ${gtf} ${fasta_flag} ${bam_flag} ${proteins_flag} ${mapping_flag} \
        ${scores_flag} ${reference_gtf_flag} ${reference_fasta_flag} ${iterative_flag} ${output_flag}
    """
}