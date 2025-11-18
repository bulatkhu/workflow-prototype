params.outdir  = "results"

process comet_search {
    publishDir "${params.outdir}/comet", mode: 'copy'
    container "comet:2025.03"

    input:
        path raw
        path fasta
        path comet_params_file

    // output:
    // path "${raw.baseName}.pep.xml"
    output:
        path("*.pep.xml"), emit: pepxml
        // path("*.pin"), emit: pin
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    // script:
    // """
    // comet \
    //     -P${comet_params_file} \
    //     -D${fasta} \
    //     -N${raw.baseName} \
    //     ${raw} \
    //     1>${raw.baseName}.comet.stdout 2>${raw.baseName}.comet.stderr

    // echo "COMET SEARCH DONE!" # Needed for proper exit
    // """
    script:
    """
    comet \
        -P${comet_params_file} \
        -D${fasta} \
        ${raw} \
        1>${raw.baseName}.comet.stdout 2>${raw.baseName}.comet.stderr

    echo "COMET SEARCH DONE!" # Needed for proper exit
    """
}
