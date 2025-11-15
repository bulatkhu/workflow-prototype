params.outdir  = "results"

process transdecoder_process {
    label 'transdecoder'
    input:
    path reads

    output:
    path "${reads.baseName}.transcripts.fa"

    publishDir "${params.outdir}", mode: 'copy'

    script:
    """
    TransDecoder.LongOrfs -t ${reads}
    TransDecoder.Predict -t ${reads}
    cp ${reads.baseName}.transdecoder.pep ${reads.baseName}.proteins.faa
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
