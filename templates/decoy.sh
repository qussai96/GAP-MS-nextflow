#!/bin/bash

# EXAMPLE USAGE: AddDecoyFASTA.sh -i ~/Downloads/FragTest/IRGSP-1.0_protein_2021-11-11.fasta -o ./temp

echo ${fasta_file}

# Check if input FASTA file exists
if [ ! -f "${fasta_file}" ]; then 
    echo "Input FASTA file does not exist"
    exit 1 
fi

printf '%.0s-' {1..55}
echo ""
echo "Adding decoy and contaminant sequences to FASTA file"
printf '%.0s-' {1..55}
echo ""
echo "Parameters:"
echo "Input FASTA: ${fasta_file}"


FASTANAME=\$(basename ${fasta_file})
DATENOW=\$(date +"%Y-%m-%d")

echo Checking decoys in ${fasta_file}
       
if grep -q "${decoy_tag}" "${fasta_file}"; then
    cat "${fasta_file}" > decoy_fasta_results.fasta
    echo "Decoys found in the fasta file, proceeding"
else
    echo "Decoys not found in the fasta file, adding decoys"

    # Add decoy and contaminant sequences
    echo "philosopher workspace --init"
    philosopher workspace --init

    if [ "${add_contaminants}" = "true" ]; then
        echo "Add contaminants: yes"
        philosopher database --custom "${fasta_file}" --contam
    else
        echo "Add contaminants: no"
        philosopher database --custom "${fasta_file}"
    fi
    philosopher workspace --clean


    mv *.fas decoy_fasta_results.fasta && \
echo "Decoy and contaminant sequences added to FASTA file"

fi


