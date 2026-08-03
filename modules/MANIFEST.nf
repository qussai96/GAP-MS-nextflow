#!/usr/bin/env nextflow

//wrie default = mode -= DDA+ 
process MANIFEST{
    publishDir "Fragpipe_output/manifest", mode: 'copy'
    
    input:
        val ready
        val input_folder
        val mode_type

    output:
        path 'manifest.fp-manifest', emit: manifest

    script:
    """

    if [[ -d "${input_folder}" ]]; then

        for file in "${input_folder}"/*.{raw,RAW}; do

            [ -e "\$file" ] || continue

            filename=\$(basename "\$file")
            filename_no_ext="\${filename%.*}"

            # Split the filename by underscores into an array
            IFS='_' read -r -a parts <<< "\$filename_no_ext"

            # Extracting the last part --> replicate num 
            raw_replicate="\${parts[-1]}"
            replicate="\${raw_replicate//[Rr]/}"

            # Extracting the sample ID
            raw_id="\${parts[2]}"
            sample_id="\${raw_id//[Pp]/}"

            absolute_path=\$(readlink -f "\$file")

            echo -e "\${absolute_path}\t\${sample_id}\t\${replicate}\t${mode_type}" >> manifest.fp-manifest

    done
    else
        echo "Input is not a valid directory."
        exit 1
    fi
    """
}