#!/usr/bin/env nextflow

//modules
include { fragpipe_workflow } from './subworkflows/local/fragpipe_workflow.nf'
include { gene_prediction } from './subworkflows/local/gene_prediction.nf'
include { varus_workflow } from './subworkflows/local/varus_workflow.nf'
include { GAPMS } from './modules/GAPMS.nf'

workflow{

    if (!params.raw_ms_files || !params.fasta_file) {
        error " --raw_ms_files and --fasta_file are not defined. Please provide the raw mass spectrometry files and fasta file."
    }

    fasta_ch = Channel.fromPath(
        params.fasta_file,
        checkIfExists: true
    )

    genome_fasta = Channel.fromPath(
        params.genome_fasta,
        checkIfExists: true
    )
        
    fragpipe_workflow (
        params.raw_ms_files,
        fasta_ch
    )
    
    gene_prediction(
        params.genome_option,
        genome_fasta
    )

    def ch_varus = Channel.value(file("NO_FILE"))
    def assembly = Channel.value(file("NO_FILE"))

    if (params.taxID) { //if there is taxID VARUS is strated and BAM files are generated 
        varus_workflow(
            params.taxID,
            genome_fasta
        )
        ch_varus = varus_workflow.out.varus_results
        assembly = genome_fasta //required if VARUS is started
    }

    GAPMS(
        fragpipe_workflow.out.fragpipe_results, // -p takes peptide.tsv //always 
        gene_prediction.out.gtf_results,  // -g; alway needed 
        gene_prediction.out.faa_results, // -f
        assembly, // -a; needed if -b
        ch_varus //-b; needs -a
    )
}
