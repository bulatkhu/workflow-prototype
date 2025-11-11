process msfragger_search {
    input:
    path raw
    path merged_db
    val threads

    output:
    path "${raw.baseName}_msfragger.txt"

    script:
    """
    echo "Simulating MSFragger search on: ${raw} using DB: ${merged_db}" > ${raw.baseName}_msfragger.txt
    echo "Threads used: ${threads}" >> ${raw.baseName}_msfragger.txt
    """
}
