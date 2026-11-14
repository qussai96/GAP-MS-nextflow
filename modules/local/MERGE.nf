process MERGE{
    stageInMode 'copy'

    publishDir "${projectDir}/Fragpipe_output/database", mode: 'copy'

    input:
    path fasta_file
    path faa_results
    path varus_results

    output:
    path "combined_fasta.fasta", emit: combined_fasta

    script:
    """
    files=""
    for f in "${fasta_file}" "${faa_results}" "${varus_results}"; do
        if [ -s "\$f" ] && [ "\$(basename "\$f")" != "NO_FILE" ]; then
            files="\$files \$f"
        fi
    done

    if [ -n "\$files" ] ; then
        cat \$files > combined_fasta.fasta
    else
        echo "No valid FASTA files available to merge" >&2
        exit 1
    fi
    """
}