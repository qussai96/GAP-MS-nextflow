include { casanovo_workflow } from '../subworkflows/local/casanovo_workflow.nf'
include { fragpipe_workflow } from '../subworkflows/local/fragpipe_workflow.nf'
include { gene_prediction } from '../subworkflows/local/gene_prediction.nf'
include { reference_fasta_workflow } from '../subworkflows/local/reference_fasta_workflow.nf'
include { varus_workflow } from '../subworkflows/local/varus_workflow.nf'
include { GAPMS } from '../modules/local/GAPMS.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow GAP_FLOW {

    if (!params.raw_ms_files || !params.genome_fasta) {
        error " --raw_ms_files and --genome_fasta are not defined. Please provide the raw mass spectrometry files and genome fasta file."
    }

    fasta_ch = params.fasta_file // fasta file is optional, if not provided, the workflow will take the fasta file from Tiberius/Helixer output 
        ? Channel.fromPath(params.fasta_file,checkIfExists: true)
        : Channel.empty()

    genome_fasta = Channel.fromPath(
        params.genome_fasta,
        checkIfExists: true
    )
    
    gene_prediction(
        params.genome_option, 
        genome_fasta
    )

    def ch_varus = Channel.value(file("${projectDir}/assets/placeholder_files/NO_BAM")) // Initialize ch_varus channel & path to placeholder file
    def varus_faa = Channel.value(file("${projectDir}/assets/placeholder_files/NO_FILE")) // Initialize varus_faa channel
    def assembly = genome_fasta

    if (params.taxID && params.rna_seq_bam) { //if there is taxID VARUS is strated and BAM files are generated 
        error "Please provide either --taxID or --rna_seq_bam, not both."
    }

    if (params.taxID  || params.rna_seq_bam) { //if there is taxID VARUS is strated and BAM files are generated 
        varus_workflow(
            params.taxID,
            genome_fasta
        )
        ch_varus = varus_workflow.out.varus_results // VARUS BAM file for GAPMS
        varus_faa = varus_workflow.out.varus_faa // VARUS faa file for MERGE process in Fragpipe workflow
    }


    //Peptide identification with an option to provide an ready peptide.tsv file directly to GAPMS
    if (params.peptide_identification == "casanovo") {
        casanovo_workflow(
            params.raw_ms_files
        )
        peptides = casanovo_workflow.out.casanovo_results // peptide.tsv for GAPMS
    }
    else if (params.peptide_identification == "fragpipe") {
        fragpipe_workflow (
            params.raw_ms_files,
            fasta_ch, 
            gene_prediction.out.faa_results, 
            varus_faa
        )
        peptides = fragpipe_workflow.out.fragpipe_results // peptide.tsv for GAPMS
    } else if (file(params.peptide_identification).isDirectory()) {
        peptides = Channel
            .fromPath("${params.peptide_identification}/**/peptide.tsv",
                      checkIfExists: true)
            .collect()

    }
    else if (file(params.peptide_identification).isFile() && file(params.peptide_identification).name == 'peptide.tsv') {

        peptides = Channel.fromPath(
            params.peptide_identification,
            checkIfExists: true
        )
    } else {
        error "Invalid value for --peptide_identification. Please provide 'casanovo', 'fragpipe', or a path to a peptide identification TSV file or folder with TSV files."
    }

    ref_gtf = params.ref_gtf 
        ? Channel.fromPath(params.ref_gtf, checkIfExists: true)
        : Channel.value(file("${projectDir}/assets/placeholder_files/NO_REF_GTF")) // Initialize ref_gtf channel & path to placeholder file
    
    reference_fasta = Channel.value(file("${projectDir}/assets/placeholder_files/NO_REF_FASTA")) // Initialize reference_fasta channel
    def create_reference_fasta = params.ref_fasta?.toString()?.toBoolean() // Convert to boolean, default to false if not provided

    if (create_reference_fasta) {

        reference_fasta_workflow(
            genome_fasta,
            ref_gtf
        )
        reference_fasta = reference_fasta_workflow.out.ready_ref_fasta
        
    }
    
    
    GAPMS(
        peptides, // -p takes peptide.tsv //always 
        gene_prediction.out.gtf_results,  // -g; alway needed 
        gene_prediction.out.faa_results, // -f
        assembly, // -a; needed
        ch_varus, //-b; needs -a
        ref_gtf, //-rg (optional)
        reference_fasta //-rf (optional)
    )

}