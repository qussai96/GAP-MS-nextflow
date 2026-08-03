#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process HELIXER{
    publishDir "prediction_output", mode: 'copy'

    //https://github.com/usadellab/Helixer/tree/main
    container "docker://gglyptodon/helixer-docker:latest"

    input:
    path fasta_file
    val lineage_helixer

    output:
    path "*.gff3", emit: helixer_results

    script:
    """

    export TMPDIR="\$PWD/scratch_tmp"
    mkdir -p "\$TMPDIR"

    MODEL_DIR=\$PWD/helixer_models

    if [ ! -d "\$MODEL_DIR" ]; then
        mkdir -p \$MODEL_DIR
    fi

    if [ ! -d "\$MODEL_DIR/${lineage_helixer}" ]; then
        echo "Downloading Helixer models..."
        fetch_helixer_models.py --custom-path \$MODEL_DIR
    fi

    if [ ! -e "${fasta_file}" ]; then 
        echo "File does not exist"
        exit 1
    fi

    header=\$(grep "^>" ${fasta_file} | head -n 1)

    species=\$(echo \$header | awk '{print \$2}')

    output_name=\$(echo \$header| awk '{print \$2"_"\$3"_"\$4"_"\$5}')

            
    Helixer.py \
        --fasta-path ${fasta_file} \
        --species \${species} \
        --lineage ${lineage_helixer} \
        --downloaded-model-path \$MODEL_DIR \
        --gff-output-path "\${output_name}.gff3"
    """

}