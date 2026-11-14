#!/usr/bin/env nextflow

//wrie default = mode -= DDA+ 
process MANIFEST{
    stageInMode 'copy'
    //cache 'false'

    publishDir "${projectDir}/Fragpipe_output/manifest", mode: 'copy'
    
    input:
        val ready
        val raw_ms_files
        val mode_type

    output:
        path 'manifest.fp-manifest', emit: manifest

    script:
    //raw file name: experimentName_soemthing_1.raw
    """
    if [[ -d "${raw_ms_files}" ]]; then

        for file in "${raw_ms_files}"/*.{raw,RAW}; do

            [ -e "\$file" ] || continue

            filename=\$(basename "\$file")
            filename_no_ext="\${filename%.*}"

            # Split the filename by underscores into an array
            IFS='_' read -r -a parts <<< "\$filename_no_ext"

            sample_id="\${parts[0]}"

            if [[ "\${#parts[@]}" -gt 1 ]]; then
                last_part="\${parts[\${#parts[@]}-1]}"
                case "\$last_part" in
                    ''|*[!0-9]*)
                        replicate="0"
                        ;;
                    *)
                        replicate="\$last_part"
                        ;;
                esac
            else
                replicate="0"
            fi

            absolute_path=\$(readlink -f "\$file")

            echo -e "\${absolute_path}\t\${sample_id}\t\${replicate}\t${mode_type}" >> manifest.fp-manifest

    done
    else
        echo "Input is not a valid directory."
        exit 1
    fi
    """
}