#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//SUBWORKFLOW

//modules 
include { GET_TAXONOMY } from '../../modules/GET_TAXONOMY.nf'
include { VARUS } from '../../modules/VARUS.nf'
include { BAM_TO_GTF } from '../../modules/BAM_TO_GTF.nf'
include { GFF_GTF_TO_FAA } from '../../modules/GFF_GTF_TO_FAA.nf'
include { TRANSDECODER } from '../../modules/TRANSDECODER.nf'

workflow varus_workflow{
    take:
        taxID
        genome_fasta

    main:
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

        BAM_TO_GTF(
            VARUS.out.varus_results
        )

        GFF_GTF_TO_FAA(
            BAM_TO_GTF.out.varus_gtf,
            genome_fasta,
            "-w",
            "varus.fasta",
            //"VARUS_output"
        )

        TRANSDECODER(
            GFF_GTF_TO_FAA.out.fasta
        )

    emit:
        //varus_results  = VARUS.out.map { output_dir -> file("${output_dir}/*.bam") }
        varus_results = VARUS.out.varus_results
        varus_faa = TRANSDECODER.out.varus_faa //input to MERGE process 
}