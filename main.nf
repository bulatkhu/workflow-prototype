#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import processes from modules
include { transdecoder_process } from './modules/transdecoder.nf'
include { translate_proteins }   from './modules/transdecoder.nf'
include { comet_search }   from './modules/comet_search.nf'
include { merge_databases }      from './modules/merge_db.nf'

// Define input parameters
params.reads   = "data/reads/*.fastq.gz"
params.fasta   = "data/reference/proteome.fasta"
params.outdir  = "results"
params.msraw   = "data/ms/*.mzML"

workflow {
    comet_params = file(params.comet_params, checkIfExists: true)

    reads_ch = channel.fromPath(params.reads)
    fasta_ch = channel.fromPath(params.fasta)
    ms_ch    = channel.fromPath(params.msraw)

    translated = transdecoder_process(reads_ch)
    proteins   = translate_proteins(translated)
    merged_db  = merge_databases(proteins, fasta_ch)
    ms_results = comet_search(ms_ch, merged_db, comet_params)
    
}
