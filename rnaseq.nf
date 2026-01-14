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

params.samplesheet = "data/samplesheet.csv"
params.fasta = "data/reference/Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
params.genome = "data/genome/Homo_sapiens.GRCh38.114.chr.gtf.gz"

workflow {
    samplesheet_ch  = channel.fromPath(params.samplesheet)
    fasta_ch        = channel.fromPath(params.fasta)
    genome_ch       = channel.fromPath(params.genome)
    
    rnaseq_wrapper(
        samplesheet_ch,
        fasta_ch,
        genome_ch
    )
}
