params.outdir  = "results"

process gffcompare {
    publishDir "${params.outdir}/novel/gffcompare", mode: 'copy'
    container "quay.io/biocontainers/gffcompare:0.12.10--h9948957_0"

    tag "finding novel transcripts"

    input:
    tuple val(meta), path(transcripts)
    path reference_gtf

    output:
    tuple val(meta), path("compare_denovo.annotated.gtf"), emit: annotated
    tuple val(meta), path("compare_denovo.stats"),           emit: stats
    tuple val(meta), path("compare_denovo.tracking"),        emit: tracking
    tuple val(meta), path("novel_intergenic.gtf"),    emit: intergenic
    tuple val(meta), path("novel_transcripts_all.gtf"), emit: novel_all

    script:
    """
    gffcompare -r ${reference_gtf} -o compare_denovo ${transcripts}

    # extract intergenic-only transcripts (class_code = "u")
    awk '\$0 ~ /class_code "u"/' compare_denovo.annotated.gtf > novel_intergenic.gtf

    # extract all non-canonical transcripts (not class_code "=")
    awk '\$3=="transcript" && \$0 !~ /class_code "="/' compare_denovo.annotated.gtf > novel_transcripts_all.gtf
    """
}
