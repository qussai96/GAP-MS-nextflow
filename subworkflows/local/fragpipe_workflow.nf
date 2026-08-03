#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//SUBWORKFLOW

//modules
include { AUTHENTICATION } from '../../modules/AUTHENTICATION.nf'
include { AUTHENTICATION_DOWNLOAD } from '../../modules/AUTHENTICATION.nf'
include { MANIFEST } from '../../modules/MANIFEST.nf'
include { DECOY } from '../../modules/DECOY.nf'
include { WORKFLOW } from '../../modules/WORKFLOW.nf'
include { FRAGPIPE } from '../../modules/FRAGPIPE.nf'

include { addDownloadInformation; token; checkEmailForToken } from '../../config_tools_setup/config_tools_init.nf'


workflow fragpipe_workflow {
    take:
        raw_ms_files
        fasta_ch  

    main:
        def msfragger_jar_ch = Channel.empty()
        def ionquant_jar_ch = Channel.empty()
        def diatracer_jar_ch = Channel.empty()
        def ready = Channel.of(true) //ensures that other processes do not start before the config tools are downloaded
        
        def tools_dir = file("${projectDir}/config-tools")
        def tools_already_present = tools_dir.exists() && 
            tools_dir.listFiles()?.any { it.name.startsWith("MSFragger") } &&
            tools_dir.listFiles()?.any { it.name.startsWith("IonQuant") } &&
            tools_dir.listFiles()?.any { it.name.toLowerCase().startsWith("diatracer") }


        // If the user has already downloaded the config tools and provided the path to the folder, the tool files are copied into config-tools folder in the project directory
        if (params.config_tools_folder || tools_already_present) {

            if (params.config_tools_folder) {
                def source_tools = file(params.config_tools_folder)
                def destination_tools = file("${projectDir}/config-tools")

                destination_tools.mkdirs()

                source_tools.eachDir { dir ->

                    if (dir.name.startsWith("MSFragger") || dir.name.startsWith("IonQuant") || dir.name.startsWith("DiaTracer") ) {

                        println "COPY TOOL FOLDER: ${dir}"

                        def destination = file("${destination_tools}/${dir.name}")

                        if (!destination.exists()) {
                            destination.mkdirs()
                        }

                        dir.eachFileRecurse { child ->

                            def relative_path = dir.relativize(child)

                            def target = file("${destination}/${relative_path}")

                            if (child.isDirectory()) {
                                target.mkdirs()
                            }
                            else {
                                target.parent.mkdirs()
                                target.bytes = child.bytes
                            }
                        }
                    }
                }

            }
            msfragger_jar_ch = Channel.fromPath("${projectDir}/config-tools/MSFragger-*/MSFragger*.jar")
            ionquant_jar_ch = Channel.fromPath("${projectDir}/config-tools/IonQuant-*/IonQuant*.jar")
            diatracer_jar_ch = Channel.fromPath("${projectDir}/config-tools/diaTracer-*/diaTracer*.jar")
            ready = Channel.of(true)
        }

        // If the tools are not already present, the download process beginns 
        else {
            def inf = addDownloadInformation()

            auth_ch = AUTHENTICATION(
                true,
                inf.download_first_name,
                inf.download_last_name,
                inf.download_email,
                inf.download_institution,
                inf.license_accept
            )
                
            auth_ch
                .map {
                    println "Authentication request finished"
                    checkEmailForToken()
                    token()
                }
                .set { auth_token }


            AUTHENTICATION_DOWNLOAD(auth_token)

            msfragger_jar_ch = AUTHENTICATION_DOWNLOAD.out.msfragger_jar
            ionquant_jar_ch = AUTHENTICATION_DOWNLOAD.out.ionquant_jar
            diatracer_jar_ch = AUTHENTICATION_DOWNLOAD.out.diatracer_jar

            ready = AUTHENTICATION_DOWNLOAD.out.diatracer_jar
                .map { true }
            
        }

        raw_ms_files_ch = Channel.value(params.raw_ms_files)

        MANIFEST(
            ready, //ensures that it does not start before EVERY config tool is downloaded
            raw_ms_files_ch,
            params.mode_type      
        )

        DECOY(
            ready,
            fasta_ch,
            params.add_contaminants,
            params.decoy_tag
        )

        workflow_template = Channel.fromPath(
            "${projectDir}/assets/workflow_template.workflow",
            checkIfExists: true
        )

        WORKFLOW(
            workflow_template,
            DECOY.out.decoy_results
        )

        FRAGPIPE(
            msfragger_jar_ch,
            DECOY.out.decoy_results,
            WORKFLOW.out.workflow,
            MANIFEST.out.manifest,
            params.ram,
            params.threads
        )
        
    emit:
        fragpipe_results  = FRAGPIPE.out.map { output_dir -> file("${output_dir}/**/peptide.tsv") }

}