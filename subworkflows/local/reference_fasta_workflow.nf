#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { GFF_GTF_TO_FAA } from '../../modules/local/GFF_GTF_TO_FAA.nf'

workflow reference_fasta_workflow{
    take:
        genome_fasta
        ref_gtf

    main:
        GFF_GTF_TO_FAA(
            ref_gtf,
            genome_fasta,
            "-y", // mode
            "reference.faa", // output_name
            //"prediction_output" // publish_dir
        )

    emit:
        ready_ref_fasta = GFF_GTF_TO_FAA.out.fasta //reference.faa for GAPMS
}