params.outdir  = "results"

process filter_by_score {
    publishDir "${params.outdir}", mode: 'copy'

    tag "filtering proteins by score threshold"

    input:
        path proteins_pep
        val min_score_threshold
        val max_score_threashold

    output:
        path("*.pep"), emit: pep

    script:
    """
    awk '
    /^>/ {
        if (\$0 ~ /score=/) {
            split(\$0, a, "score=")
            split(a[2], b, " ")
            score = b[1]
            keep = (score >= ${min_score_threshold} && score <= ${max_score_threashold})
        } else {
            keep = 0
        }
    }
    keep { print }
    ' ${proteins_pep} > transdecoder.score_min_${min_score_threshold}_to_max_${max_score_threashold}.pep
    """
}