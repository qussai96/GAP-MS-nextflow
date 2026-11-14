#!/usr/bin/env nextflow

process MZTAB_TO_TSV{

    //container "community.wave.seqera.io/library/python_mztabpy:d9b29f5dddde24e4"

    //container 'docker.io/library/python:3.13-slim-trixie'
    //container 'community.wave.seqera.io/library/python_pip_procps-ng:8d89233643fae582'

    input:
    path casanovo_results

    output:
    path "peptide.tsv", emit: casanovo_tsv

    script: 
    //https://github.com/WangHong007/mztabpy
    //https://casanovoutils.readthedocs.io/en/latest/
    //https://hub.docker.com/_/python 
    """
    mapfile -t mztab_files < <(find -L . -type f -name "*.mztab" | sort)

    if [ \${#mztab_files[@]} -eq 0 ]; then
        echo "ERROR: No mzTab files found!"
        exit 1
    fi

    echo "Found \${#mztab_files[@]} mzTab files"

    i=0

    #goes inside the folder and converts all mztab files to tsv files
    for mztab in "\${mztab_files[@]}"; do
        i=\$((i + 1))

        header=false

        first_header=\$(awk -F '\\t' '\$1 == "PSH" {sub(/^[^\\t]*\\t/, "") 
        print 
        exit}' "\$mztab")
            
        printf '%s\\n' "\$first_header" > "converted_\$i.tsv"
        
            
        awk -F '\\t' '\$1 == "PSM" {sub(/^[^\\t]*\\t/, "") 
            print }' "\$mztab" >> "converted_\$i.tsv"
            
    done

    tsv_files=(converted_*.tsv)

    first_file=true

    for file in "\${tsv_files[@]}"; do

        if [ "\$first_file" = true ]; then

            awk -F '\\t' -v score="${params.peptide_score}" '
                FNR == 1 {
                    for (i = 1; i <= NF; i++) {
                        if (\$i == "search_engine_score[1]") score_col = i
                    }

                    if (!score_col) {
                        print "ERROR: search_engine_score[1] column not found" > "/dev/stderr"
                        exit 1
                    }

                    print
                    next
                }

                \$score_col >= score {
                    print
                }
            ' "\$file" > peptide.tsv

            first_file=false

        else

            awk -F '\\t' -v score="${params.peptide_score}" '
                FNR == 1 {
                    for (i = 1; i <= NF; i++) {
                        if (\$i == "search_engine_score[1]") score_col = i
                    }

                    if (!score_col) {
                        exit 1
                    }

                    next
                }

                \$score_col >= score {
                    print
                }
            ' "\$file" >> peptide.tsv

        fi

    done

    """
    //filtering 
}