#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//SUBWORKFLOW

//modules 
include { GET_TAXONOMY } from '../../modules/GET_TAXONOMY.nf'
include { VARUS } from '../../modules/VARUS.nf'

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

    emit:
        //varus_results  = VARUS.out.map { output_dir -> file("${output_dir}/*.bam") }
        varus_results = VARUS.out.varus_results
}