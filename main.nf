#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import processes from modules
include { transdecoder_process } from './modules/transdecoder.nf'
include { translate_proteins }   from './modules/transdecoder.nf'
include { merge_databases }      from './modules/merge_db.nf'
include { msfragger_search }     from './modules/msfragger.nf'

// Define input parameters
params.reads   = "data/reads/*.fastq.gz"
params.fasta   = "data/reference/proteome.fasta"
params.outdir  = "results"
params.msraw   = "data/ms/*.raw"
params.threads = 8

workflow {
    reads_ch = Channel.fromPath(params.reads)
    fasta_ch = Channel.fromPath(params.fasta)
    ms_ch    = Channel.fromPath(params.msraw)

    translated = transdecoder_process(reads_ch)
    proteins   = translate_proteins(translated)
    merged_db  = merge_databases(proteins, fasta_ch)
    ms_results = msfragger_search(ms_ch, merged_db, params.threads)
    
}

// workflow {

//     Channel
//         .fromPath(params.reads)
//         .view { "reads_ch → ${it}" }
//         .set { reads_ch }

//     translated = transdecoder_process(reads_ch)
//     translated
//         .view { "translated → ${it}" }
    

//     proteins   = translate_proteins(translated)
//     merged_db  = merge_databases(proteins, Channel.fromPath(params.fasta))

//     ms_files   = Channel.fromPath(params.msraw)
//     ms_results = msfragger_search(ms_files, merged_db, params.threads)

//     emit:
//         merged_db
//         ms_results
// }
