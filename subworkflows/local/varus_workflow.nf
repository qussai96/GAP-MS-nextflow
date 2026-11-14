#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//SUBWORKFLOW

//modules 
include { GET_TAXONOMY } from '../../modules/local/GET_TAXONOMY.nf'
include { VARUS } from '../../modules/local/VARUS.nf'
include { BAM_TO_GTF } from '../../modules/local/BAM_TO_GTF.nf'
include { GFF_GTF_TO_FAA } from '../../modules/local/GFF_GTF_TO_FAA.nf'
include { TRANSDECODER } from '../../modules/local/TRANSDECODER.nf'

workflow varus_workflow{
    take:
        taxID
        genome_fasta

    main:

        if (taxID){ //if there is taxID VARUS is strated and BAM files are generated{

            GET_TAXONOMY(
                taxID
            )

            //transforming path into value 
            genus   = GET_TAXONOMY.out.genus.map { it.text.trim() }
            species = GET_TAXONOMY.out.species.map { it.text.trim() }

            VARUS(
                genome_fasta,
                genus,
                species
            )
            results_ch = VARUS.out.varus_results
        }
        else{
            results_ch = Channel.fromPath(params.rna_seq_bam, checkIfExists: true)
        }

        BAM_TO_GTF(
            results_ch
        )

        GFF_GTF_TO_FAA(
            BAM_TO_GTF.out.varus_gtf,
            genome_fasta,
            "-w",
            "varus.fasta",
            //"VARUS_output"
        )

        if (params.peptide_identification == "fragpipe") {
            TRANSDECODER(
                GFF_GTF_TO_FAA.out.fasta
            )
            varus_to_merge = TRANSDECODER.out.varus_faa //input to MERGE process 
        } else{
            varus_to_merge = Channel.empty() //if fragpipe is not used there is no need for it 
        }


    emit:
        //varus_results  = VARUS.out.map { output_dir -> file("${output_dir}/*.bam") }
        varus_results = results_ch //VARUS or users BAM file 
        varus_faa = varus_to_merge //VARUS faa file for MERGE process in Fragpipe workflow
}