process comet_search {
    label 'comet'

    input:
    path raw
    path fasta
    path comet_params_file

    output:
    path "${raw.baseName}.pep.xml"

    publishDir "${params.outdir}/comet", mode: 'copy'

    script:
    """
    comet \
        -P${comet_params_file} \
        -D ${fasta} \
        -N ${raw.baseName} \
        ${raw}
    """
}
