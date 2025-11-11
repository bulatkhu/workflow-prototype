process merge_databases {

    tag { "${sample_proteins.baseName}" }

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


// process merge_databases {
//     input:
//     path sample_proteins
//     path ref_fasta
//     output:
//     path "merged_${sample_proteins.baseName}.fasta"


//     script:
//     """
//     cat ${ref_fasta} ${sample_proteins} > merged_${sample_proteins.baseName}.fasta
//     # optional: run CD-HIT to remove redundancy
//     cdhit -i merged_${sample_proteins.baseName}.fasta -o merged_${sample_proteins.baseName}.cdhit.fasta -c 0.95 -n 5
//     cp merged_${sample_proteins.baseName}.cdhit.fasta merged_${sample_proteins.baseName}.fasta
//     """
// }