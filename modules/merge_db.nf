process merge_databases {
    publishDir "${params.outdir}", mode: 'copy'
    input:
    path sample_proteins
    path ref_fasta

    output:
    path "merged_${sample_proteins.baseName}.fasta"

    script:
    """
    gunzip -c ${ref_fasta} > ${ref_fasta.baseName}.fasta
    cat ${ref_fasta.baseName}.fasta ${sample_proteins} > merged_${sample_proteins.baseName}.fasta
    """
}