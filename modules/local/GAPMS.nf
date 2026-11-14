#!/usr/bin/env nextflow

process GAPMS{
    stageInMode 'copy'

    publishDir "${projectDir}/GAPMS_output/", mode: 'copy'

    container "oras://docker.io/qussaiab96/gapms:latest"

    input:
    path peptides, stageAs: 'peptide???.tsv' // -p //if many files, gives each file a unique name 
    path gtf // -g
    path proteins // -f
    path fasta_file //-a
    path bam //-b
    path ref_gtf //-rg 
    path reference_fasta //-rf
  

    output:
    path "results/**"


    script:
    def output_dir  = (params.output && params.output != "null") ? params.output : "results"
    def output_flag = "-o ${output_dir}"

    def gtf_flag      = gtf ? "-g ${gtf}" : ""
    def fasta_flag    = fasta_file ? "-a ${fasta_file}" : "" //change it always required 
    def bam_flag      = (bam && bam.name != 'NO_BAM') ? "-b ${bam}"       : ""
    def proteins_flag = proteins ? "-f ${proteins}" : "" 
    def mapping_flag  = params.mapping ? "-m ${params.mapping}" : "" 
    def scores_flag  = params.scores ? "-s ${params.scores}" : "" 
    def reference_gtf_flag  = (ref_gtf && ref_gtf.name != 'NO_REF_GTF') ? "-rg ${ref_gtf}" : ""
    def reference_fasta_flag  = (reference_fasta && reference_fasta.name != 'NO_REF_FASTA') ? "-rf ${reference_fasta}" : ""
   // def iterative_flag  = params.iterative ? "-i" : "" 
    
    """
    # find avery peptide.tsv file and concatinate > combined_all_peptides.tsv 
    header=1

    for file in peptide*.tsv; do
        if ((header)); then
            head -n 1 "\$file" > combined_all_peptides.tsv
            header=0
        fi
        tail -n +2 "\$file" >> combined_all_peptides.tsv
    done
    # Extracts just the needed peptide sequence column 1 this way skipping the header
    awk -F'\\t' 'NR>1 {print \$1}' combined_all_peptides.tsv > clean_peptides.tsv

    wc -l clean_peptides.tsv

    gapms -p clean_peptides.tsv ${gtf_flag} ${fasta_flag} ${bam_flag} ${proteins_flag} ${mapping_flag} \
        ${scores_flag} ${reference_gtf_flag} ${reference_fasta_flag} ${output_flag} 
    """
}