params.outdir  = "results"

process rnaseq_wrapper {
    publishDir "${params.outdir}/rnaseq", mode: 'copy'

    input:
        // tuple val(meta), path(reads)
        path input
        path fasta
        path genome

    output:
    path "results"

    script:
    """
    nextflow run \
    nf-core/rnaseq \
    --input ${input} \
    --gtf ${genome} \
    --fasta ${fasta} \
    --aligner star_salmon \
    --skip_pseudo_alignment \
    --with_stringtie \
    --save_align_intermeds \
    --outdir ${params.outdir}/rnaseq \
    -profile docker
    """
}

//   !! Only displaying parameters that differ from the pipeline defaults !!
//   ------------------------------------------------------
//   * The pipeline
//       https://doi.org/10.5281/zenodo.1400710

//   * The nf-core framework
//       https://doi.org/10.1038/s41587-020-0439-x

//   * Software dependencies
//       https://github.com/nf-core/rnaseq/blob/master/CITATIONS.md

//   Genome fasta file not specified with e.g. '--fasta genome.fa' or via a detectable config file. You must supply a genome FASTA file or use --skip_alignment and provide your own transcript fasta using --transcript_fasta for use in quantification.