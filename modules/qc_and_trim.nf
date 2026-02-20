process qc_and_trim {
    tag "${reads.baseName}"
    publishDir "${params.outdir}/qc", mode: 'copy'
    container "quay.io/biocontainers/fastp:1.0.1--heae3180_0"

    input:
    path reads

    output:
    path "trimmed_${reads}", emit: trimmed_reads
    path "*.html", emit: report

    script:
    """
    fastp -i ${reads} -o trimmed_${reads} -h ${reads.baseName}_fastp.html
    """
}