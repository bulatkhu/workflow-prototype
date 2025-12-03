params.outdir  = "results"

process stringtie_mixed {
    publishDir "${params.outdir}/novel/stringtie_mixed", mode: 'copy'
    container "quay.io/biocontainers/stringtie:3.0.3--h29c0135_0"

    tag "assembling transcripts with novel discovery"

    input:
    val sample_name
    path bam
    path genome

    output:
    path("*.gtf"), emit: gtf
    // path("${meta.sample}_mixed.transcripts.gtf"), emit: gtf
    // path("*.gtf")  // alternative for file name flexibility

    script:
    """
    stringtie ${bam} \
        --mix \
        -f 0.1 \
        -c 2.5 \
        -p 8 \
        -p ${task.cpus} \
        -o ${sample_name}_mixed.transcripts.gtf

    
    echo "StringTie parameters used:" > stringtie_params.txt
    echo "-f 0.01 (isoform fraction)" >> stringtie_params.txt
    echo "-c 0.5 (coverage)" >> stringtie_params.txt
    echo "-g 10 (transcript gap)" >> stringtie_params.txt
    """
}