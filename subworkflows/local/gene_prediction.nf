#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//SUBWORKFLOW

//modules
include { TIBERIUS } from '../../modules/local/TIBERIUS.nf'
include { HELIXER } from '../../modules/local/HELIXER.nf'
include { GFF_GTF_TO_FAA } from '../../modules/local/GFF_GTF_TO_FAA.nf'

workflow gene_prediction{
    take:
        genome_option
        genome_fasta

    main: //it is done always despite the user providing the reference_gtf file (ref_gtf is an optional input for GAPMS module)
        
        if (!params.prediction_gff_file){
            if (genome_option == "Tiberius" || genome_option == "tiberius" ) {
                if (!params.model_cfg_tiberius) {
                    error "Please provide --model_cfg_tiberius for Tiberius gene prediction."
                }

                TIBERIUS (
                    genome_fasta,
                    params.model_cfg_tiberius
                )
            }

            else if (genome_option == "Helixer" || genome_option == "helixer"){
                if (!params.lineage_helixer) {
                    error "Please provide --lineage_helixer for Helixer gene prediction."
                }
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
