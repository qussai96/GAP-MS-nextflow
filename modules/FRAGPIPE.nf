#!/usr/bin/env nextflow

process FRAGPIPE {
    publishDir "Fragpipe_output/fragpipe", mode: 'copy'

<<<<<<< HEAD
    container "fcyucn/fragpipe:latest" //option: ${params.fragpipe_version} 23.1v (the same as in the GAP-MS publication)
    containerOptions "--cleanenv --writable-tmpfs --bind \$PWD,\$HOME/.config,${projectDir},${params.input_folder}"
=======
    container "fcyucn/fragpipe:latest" //opcja: ${params.fragpipe_version} 23.1v (taka sama jak w publication)
    containerOptions "--cleanenv --writable-tmpfs --bind \$PWD,\$HOME/.config,${projectDir},${params.raw_ms_files}"
>>>>>>> 97527ac (Changed input_folder to raw_ms_files)

    input:
    path msfragger_jar
    path decoy_results
    path workflow_path
    path manifest_file
    val ram
    val threads

    output:
    path "output_folder_fragpipe", emit: fragpipe_results

    script:
    """
    #Enables to use the latest version of FragPipe installed in the container
    fp_version=\$(ls /fragpipe_bin/ | grep fragpipe | cut -d'-' -f2)

    fp_run_path="/fragpipe_bin/fragpipe-\$fp_version/fragpipe-\$fp_version/bin/fragpipe"

    export HOME=\$PWD
    export FRAGPIPE_HOME=\$PWD/fragpipe_home
    
    mkdir -p \$FRAGPIPE_HOME/cache
    mkdir -p \$FRAGPIPE_HOME/jobs

    echo "Running FragPipe"
        \$fp_run_path --headless --ram ${ram} --threads ${threads} \
        --workflow "${workflow_path}" \
        --manifest "${manifest_file}" \
        --workdir "output_folder_fragpipe" \
        --config-tools-folder "${projectDir}/config-tools" 

    # rm -f output_folder_fragpipe/*.workflow

    """
}
