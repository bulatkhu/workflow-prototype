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
include { gffcompare } from './modules/gffcompare.nf'
include { stringtie_mixed } from './modules/stringtie_mixed.nf'

// Define input parameters
params.reads   = "data/reads/*.fastq.gz"
params.fasta   = "data/reference/proteome.fasta"
params.outdir  = "results"
params.msraw   = "data/ms/*.mzML"
params.samplesheet = "data/samplesheet.csv"
params.comet_params = "params/comet.params"

params.fasta1Unzip = "data/reference/Homo_sapiens.GRCh38.dna.toplevel.fa"
params.fasta1 = "data/reference/Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
params.genome1 = "data/genome/Homo_sapiens.GRCh38.114.chr.gtf.gz"
params.genomeUnzip = "data/genome/Homo_sapiens.GRCh38.114.chr.gtf"

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
    // )

    meta = [id: "THP1_test"]

    // gtf_file = file("results/rnaseq/results/rnaseq/star_salmon/stringtie/THP1_test.transcripts.gtf")
    ref_fa = file(params.genomeUnzip, checkIfExists: true)
    
    genome1_unzip = file(params.genomeUnzip, checkIfExists: true)
    bam = channel.fromPath("results/THP1_test/rnaseq/results/rnaseq/star_salmon/THP1_test.sorted.bam")

    stringtie_results = stringtie_mixed("THP1_test", bam, genome1_unzip)


    transcripts_ch = channel.of(meta).combine(stringtie_results.gtf)

    gff = gffcompare(transcripts_ch, genome1_unzip)

    // transcripts = gffread_transcripts(gtf_file, ref_fa)

    // fastqc_out = qc_and_trim(reads_ch)

    // translated = transdecoder_process(transcripts)
    // proteins   = translate_proteins(translated)
    // merged_db  = merge_databases(proteins, fasta1_ch)
    // ms_results = comet_search(ms_ch, merged_db, comet_params)
    
}
