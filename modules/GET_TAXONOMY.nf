#!/usr/bin/env nextflow

process GET_TAXONOMY{

    input:
    val taxID

    output:
    path "genus.txt", emit: genus
    path "species.txt", emit: species

    script: 
    //https://towardsdatascience.com/analyze-scientific-publications-with-e-utilities-and-python-56f76de22959/
    // https://eutilities.github.io/site/Reference_Guide/a_reference/ 
    """

    python3 -c '
    import urllib.request
    import json

    tax_id = "${taxID}"

    summary_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=taxonomy&id={tax_id}&retmode=json"

    summary_raw = urllib.request.urlopen(summary_url).read().decode("utf-8")
    result = json.loads(summary_raw)

    sci_name = result["result"][tax_id]["scientificname"]
    parts = sci_name.split(" ")

    genus = parts[0]
    species = parts[1] if len(parts) > 1 else ""

    with open("genus.txt", "w") as f:
        f.write(genus)

    with open("species.txt", "w") as f:
        f.write(species)
    '

    """
}