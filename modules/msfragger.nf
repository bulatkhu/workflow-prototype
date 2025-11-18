params.outdir  = "results"

process msfragger_search {
    publishDir "${params.outdir}/msfragger", mode: 'copy'
    input:
    path raw
    path merged_db
    val threads

    output:
    path "${raw.baseName}.pepXML"
    path "${raw.baseName}.tsv"

    script:
    """
    # Run MSFragger
    java -Xmx8G -jar /opt/MSFragger.jar \
        --threads ${threads} \
        --database ${merged_db} \
        params/fragger_params.yaml \
        ${raw}

    # MSFragger output filenames
    cp ${raw.baseName}.pepXML .
    cp ${raw.baseName}.tsv .
    """
}
