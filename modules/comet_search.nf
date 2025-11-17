process comet_search {
    label 'comet'

    input:
    path raw
    path fasta

    output:
    path "${raw.baseName}.pep.xml"

    script:
    """
    comet -P params/comet.params -D ${fasta} -N ${raw.baseName} ${raw}
    """
}
