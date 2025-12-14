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
        -G ${genome} \
        --mix \
        -f 0.1 \
        -c 2.5 \
        -p ${task.cpus} \
        -o ${sample_name}_mixed.transcripts.gtf
    """
}