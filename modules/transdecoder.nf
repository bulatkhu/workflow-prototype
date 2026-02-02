params.outdir  = "results"

process transdecoder_process {
    publishDir "${params.outdir}/transdecoder", mode: 'copy'
    label 'transdecoder'
    
    input:
    path reads


    output:
    path "*.transdecoder.pep", emit: pep
    path "*.transdecoder.cds", emit: cds
    path "*.transdecoder.gff3", emit: gff3
    path "*.transdecoder.bed", emit: bed

    script:
    """
    TransDecoder.LongOrfs -t ${reads}
    TransDecoder.Predict --single_best_only -t ${reads}
    """
}
