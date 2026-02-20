process gffcompare {
    publishDir "${params.outdir}/novel/gffcompare", mode: 'copy'
    container "quay.io/biocontainers/gffcompare:0.12.10--h9948957_0"

    tag "finding novel transcripts"

    input:
    path(transcripts)
    path reference_gtf

    output:
    path("compare_denovo.annotated.gtf"), emit: annotated
    path("compare_denovo.stats"),           emit: stats
    path("compare_denovo.tracking"),        emit: tracking
    path("novel_transcripts.gtf"),    emit: novel
    path("canonical_transcripts.gtf"), emit: canonical

    script:
    """
    gffcompare -r ${reference_gtf} -o compare_denovo ${transcripts}

    # extract non-canonical transcripts (non class_code = "u")
    awk '\$0 ~ /class_code "(j|i|x|u)"/' compare_denovo.annotated.gtf > novel_transcripts.gtf

    # extract all canonical transcripts (class_code "=")
    awk '\$3=="transcript" && \$0 !~ /class_code "="/' compare_denovo.annotated.gtf > canonical_transcripts.gtf
    """
}
