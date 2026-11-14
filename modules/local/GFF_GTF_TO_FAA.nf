#!/usr/bin/env nextflow

process GFF_GTF_TO_FAA{

    //publishDir "${publish_dir}", mode: 'copy'

    container 'docker://dceoy/gffread:latest'

    input:
    path input_file //helixer or Tiberius: gff3_or_gtf_file //gff3 or gtf 
    path genome_fasta //fasta_file // orginal fasta file given to Helixer/Tiberius
    val mode // Helixer or Tiberius: -y; Varus: -w
    val output_name // Helixer or Tiberius: prediction.faa; Varus: varus.faa
    //val publish_dir // Helixer or Tiberius: prediction_output; Varus: varus_output

    output:
    path "${output_name}", emit: fasta

    script: 
    //https://manpages.ubuntu.com/manpages/trusty/man1/gffread.1.html
    """
    gffread ${input_file} -g ${genome_fasta} ${mode} ${output_name}
    """
}