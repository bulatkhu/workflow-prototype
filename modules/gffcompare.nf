params.outdir  = "results"

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
    path("novel_intergenic.gtf"),    emit: intergenic
    path("novel_transcripts_all.gtf"), emit: novel_all

    script:
    """
    gffcompare -r ${reference_gtf} -o compare_denovo ${transcripts}

    # extract intergenic-only transcripts (class_code = "u")
    awk '\$0 ~ /class_code "u"/' compare_denovo.annotated.gtf > novel_intergenic.gtf

    # extract novel transcripts per chromosome
    awk '\$3=="transcript" {print \$1}' novel_intergenic.gtf | sort -V | uniq -c > novel_intergenic_by_chr.txt

    # extract all non-canonical transcripts (not class_code "=")
    awk '\$3=="transcript" && \$0 !~ /class_code "="/' compare_denovo.annotated.gtf > novel_transcripts_all.gtf
    """
}
