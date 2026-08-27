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
        if (!params.prediction_gff_file) {
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
        } else { // allow user to provide their own gff file for gene prediction
            results_ch = Channel.fromPath(params.prediction_gff_file, checkIfExists: true)
        }

        GFF_GTF_TO_FAA(
            results_ch,
            genome_fasta,
            "-y", // mode
            "prediction.faa", // output_name
            //"prediction_output" // publish_dir
        )

    emit:
        gtf_results = results_ch        // -g
        faa_results = GFF_GTF_TO_FAA.out.map { output_dir -> file("${output_dir}/**/prediction.faa") }   // -f

}
