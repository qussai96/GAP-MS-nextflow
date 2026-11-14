process CASANOVO {
    stageInMode 'copy'
    tag "${meta.id}"

    publishDir "${projectDir}/casanovo_output/", mode: 'copy'

    container "community.wave.seqera.io/library/python_pip_numpy_pyarrow_pruned:adc069407dac5fc0"

    input:
    tuple val(meta), path(spectra)

    output:
    path "casanovo_output/*.mztab", emit: casanovo_results

    script:
    //https://casanovo.readthedocs.io/en/latest/getting_started.html
    //https://github.com/mriffle/nf-ms-dda-casanovo/tree/main 
    //def output_root  = (params.output && params.output != "null") ? params.output : "casanovo"
    //def output_flag = "-o ${output_dir}"

    """
    mkdir -p .cache/matplotlib .cache/fontconfig .cache/numba

    export MPLCONFIGDIR="\$PWD/.cache/matplotlib"
    export XDG_CACHE_HOME="\$PWD/.cache"
    export NUMBA_CACHE_DIR="\$PWD/.cache/numba"
    export FONTCONFIG_CACHE="\$PWD/.cache/fontconfig"

    mkdir -p casanovo_output

    casanovo sequence --output_dir ./casanovo_output \
        --output_root '${meta.id}' \
        ${spectra}
    """
}