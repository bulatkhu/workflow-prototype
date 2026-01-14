#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import processes from modules
include { transdecoder_process } from './modules/transdecoder.nf'
include { comet_search }   from './modules/comet_search.nf'
include { merge_databases }      from './modules/merge_db.nf'
include { qc_and_trim }      from './modules/qc_and_trim.nf'
include { rnaseq_wrapper } from './modules/rnaseq_wrapper.nf'
include { gffread_transcripts } from './modules/gffread_transcripts.nf'
include { gffcompare } from './modules/gffcompare.nf'
include { stringtie_mixed } from './modules/stringtie_mixed.nf'

// Define input parameters
// params.reads        = "data/reads/*.fastq.gz"
// params.fasta        = "data/reference/proteome.fasta"
params.outdir       = "results"
// params.msraw        = "data/ms/*.mzML"
params.samplesheet  = "data/samplesheet.csv"
params.comet_params = "params/comet.params"

params.fasta1Unzip  = "data/reference/Homo_sapiens.GRCh38.dna.toplevel.fa"
params.fasta1       = "data/reference/Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
params.genome1      = "data/genome/Homo_sapiens.GRCh38.114.chr.gtf.gz"
params.genomeUnzip  = "data/genome/Homo_sapiens.GRCh38.114.chr.gtf"

workflow {
    samplesheet_ch    = channel.fromPath(params.samplesheet)
    fasta1_ch    = channel.fromPath(params.fasta1)
    genome1_ch    = channel.fromPath(params.genome1)
    

    rnaseq_out = rnaseq_wrapper(
        samplesheet_ch,
        fasta1_ch,
        genome1_ch
    )
    
    genome1_unzip = file(params.genomeUnzip, checkIfExists: true)

    stringtie_results = stringtie_mixed("THP1_R", rnaseq_out.sorted_bam, genome1_unzip)
    gff = gffcompare(stringtie_results.gtf, genome1_unzip)

    ref_fa = file(params.fasta1Unzip, checkIfExists: true)

    transcripts = gffread_transcripts(gff.novel, ref_fa)
    
    translated = transdecoder_process(transcripts)
}
