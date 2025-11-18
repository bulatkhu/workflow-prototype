params.outdir  = "results"

process merge_databases {
    publishDir "${params.outdir}", mode: 'copy'
    input:
    path sample_proteins
    path ref_fasta

    output:
    path "merged_${sample_proteins.baseName}.fasta"

    script:
    """
    cat ${ref_fasta} ${sample_proteins} > merged_${sample_proteins.baseName}.fasta
    """
}