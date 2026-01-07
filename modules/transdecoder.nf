params.outdir  = "results"

process transdecoder_process {
    publishDir "${params.outdir}/transdecoder", mode: 'copy'
    label 'transdecoder'
    
    input:
    path reads


    output:
    path "${reads.baseName}.transdecoder.pep", emit: pep
    path "${reads.baseName}.transdecoder.cds", emit: cds
    path "${reads.baseName}.transdecoder.gff3", emit: gff3
    path "${reads.baseName}.transdecoder.bed", emit: bed

    script:
    """
    TransDecoder.LongOrfs -t ${reads.baseName}
    TransDecoder.Predict -t ${reads.baseName}
    """
}
