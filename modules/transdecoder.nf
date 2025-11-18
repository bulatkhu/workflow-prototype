params.outdir  = "results"

process transdecoder_process {
    publishDir "${params.outdir}", mode: 'copy'
    label 'transdecoder'
    
    input:
    path reads


    output:
    path "${reads.baseName}.transcripts.fa"
    path "${reads.baseName}.transdecoder.pep"

    script:
    """
    TransDecoder.LongOrfs -t ${reads}
    TransDecoder.Predict -t ${reads}

    cp ${reads}.transdecoder.pep ${reads.baseName}.transdecoder.pep

    cp ${reads} ${reads.baseName}.transcripts.fa
    """
}


process translate_proteins {
    publishDir "${params.outdir}", mode: 'copy'
    input:
    path fa
    path pep

    output:
    path pep

    script:
    """
    # No need for anything here — TransDecoder already outputs proteins
    cat ${pep}
    """
}
