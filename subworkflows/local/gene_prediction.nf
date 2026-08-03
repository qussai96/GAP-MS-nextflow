#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//SUBWORKFLOW

//modules
include { TIBERIUS } from '../../modules/TIBERIUS.nf'
include { HELIXER } from '../../modules/HELIXER.nf'
include { GFF_GTF_TO_FAA } from '../../modules/GFF_GTF_TO_FAA.nf'

workflow gene_prediction{
    take:
        genome_option
        genome_fasta

    main:

        //config_file = file("${projectDir}/conf/slurm_generic.config")

        if (genome_option == "Tiberius" || genome_option == "tiberius"){
            TIBERIUS (
                genome_fasta,
                params.model_cfg

            )
        }

        else if (genome_option == "Helixer" || genome_option == "helixer"){
            HELIXER (
                genome_fasta,
                params.lineage_helixer
            )
        }

        results_ch = genome_option.equalsIgnoreCase("Tiberius") ? TIBERIUS.out.tiberius_results : HELIXER.out.helixer_results

        GFF_GTF_TO_FAA(
            results_ch,
            genome_fasta
        )

    emit:

        gtf_results = results_ch        // -g
        faa_results = GFF_GTF_TO_FAA.out.map { output_dir -> file("${output_dir}/**/prediction.faa") }   // -f

}