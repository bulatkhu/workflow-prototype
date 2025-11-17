params.outdir  = "results"

process transdecoder_process {
    label 'transdecoder'
    
    input:
    path reads


    output:
    path "${reads.baseName}.transcripts.fa"
    path "${reads.baseName}.transdecoder.pep"


    publishDir "${params.outdir}", mode: 'copy'

    script:
    """
    TransDecoder.LongOrfs -t ${reads}
    TransDecoder.Predict -t ${reads}

    cp ${reads}.transdecoder.pep ${reads.baseName}.transdecoder.pep

    cp ${reads} ${reads.baseName}.transcripts.fa
    """
}


process translate_proteins {
    input:
    path fa
    path pep

    output:
    path pep

    publishDir "${params.outdir}", mode: 'copy'

    script:
    """
    # No need for anything here — TransDecoder already outputs proteins
    cat ${pep}
    """
}
