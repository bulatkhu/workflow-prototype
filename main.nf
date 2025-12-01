#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import processes from modules
include { transdecoder_process } from './modules/transdecoder.nf'
include { translate_proteins }   from './modules/transdecoder.nf'
include { comet_search }   from './modules/comet_search.nf'
include { merge_databases }      from './modules/merge_db.nf'
include { qc_and_trim }      from './modules/qc_and_trim.nf'
include { rnaseq_wrapper } from './modules/rnaseq_wrapper.nf'
include { gffread_transcripts } from './modules/gffread_transcripts.nf'
include { gffcompare } from './modules/gffcompare/main.nf'

// Define input parameters
params.reads   = "data/reads/*.fastq.gz"
params.fasta   = "data/reference/proteome.fasta"
params.outdir  = "results"
params.msraw   = "data/ms/*.mzML"
params.samplesheet = "data/samplesheet.csv"
params.comet_params = "params/comet.params"

params.fasta1Unzip = "data/reference/Ecoli_k12.fasta"
params.fasta1 = "data/reference/Ecoli_k12.fasta.gz"
params.genome1 = "data/reference/Ecoli_k12.gtf.gz"
params.genomeUnzip = "data/reference/Ecoli_k12.gtf"

workflow {
    comet_params = file(params.comet_params, checkIfExists: true)

    reads_ch = channel.fromPath(params.reads)
    fasta_ch = channel.fromPath(params.fasta)
    ms_ch    = channel.fromPath(params.msraw)
  
    samplesheet_ch    = channel.fromPath(params.samplesheet)
    fasta1_ch    = channel.fromPath(params.fasta1)
    genome1_ch    = channel.fromPath(params.genome1)

    // rnaseq_out = rnaseq_wrapper(
    //     samplesheet_ch,
    //     fasta1_ch,
    //     genome1_ch
    //     // fasta: params.fasta,
    //     // gtf:  params.gtf,
    //     // outdir: "${params.outdir}/rnaseq"
    // )

    gtf_file = file("results/rnaseq/results/rnaseq/star_salmon/stringtie/ecoli1.transcripts.gtf")
    ref_fa = file(params.genomeUnzip, checkIfExists: true)

    transcripts_ch = channel
        .fromPath("results/rnaseq/results/rnaseq/star_salmon/stringtie/ecoli1.transcripts.gtf")
        .map { [ [id: "human1"], it ] }

    gff = gffcompare(transcripts_ch, ref_fa)

    // transcripts = gffread_transcripts(gtf_file, ref_fa)

    // fastqc_out = qc_and_trim(reads_ch)

    // translated = transdecoder_process(transcripts)
    // proteins   = translate_proteins(translated)
    // merged_db  = merge_databases(proteins, fasta1_ch)
    // ms_results = comet_search(ms_ch, merged_db, comet_params)
    
}
