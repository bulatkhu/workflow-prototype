params.outdir  = "results"

process transdecoder_process {
    input:
    path reads

    output:
    path "${reads.baseName}.transcripts.fa"

    publishDir "${params.outdir}", mode: 'copy'

    script:
    """
    echo ">transcript_${reads.baseName}" > ${reads.baseName}.transcripts.fa
    echo "ATGGCGGCGGCGTAG" >> ${reads.baseName}.transcripts.fa
    """
}


process translate_proteins {
    input:
    path transcripts

    output:
    path "${transcripts.baseName}.proteins.faa"

    publishDir "${params.outdir}", mode: 'copy'

    script:
    """
    echo ">protein_${transcripts.baseName}" > ${transcripts.baseName}.proteins.faa
    echo "MAAAV" >> ${transcripts.baseName}.proteins.faa
    """
}
