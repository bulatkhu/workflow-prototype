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
include { filter_by_score } from './modules/filter_by_score.nf'

workflow {
    samplesheet_ch    = channel.fromPath(params.samplesheet)
    fasta1_ch    = channel.fromPath(params.fasta1)
    genome1_ch    = channel.fromPath(params.genome1)
    

    // Conditional execution of rnaseq_wrapper
    if (params.bam) {
        log.info "Skipping rnaseq_wrapper(alignment + QC) as BAM file is provided."
        bam_ch = channel.fromPath(params.bam)
    } else {
        log.info "Running rnaseq_wrapper(alignment + QC) as no BAM file is provided."
        rnaseq_out = rnaseq_wrapper(
            samplesheet_ch,
            fasta1_ch,
            genome1_ch
        )
        bam_ch = rnaseq_out.sorted_bam
    }
    
    
    genome1_unzip = file(params.genomeUnzip, checkIfExists: true)

    stringtie_results = stringtie_mixed("THP1_R", bam_ch, genome1_unzip)
    gff = gffcompare(stringtie_results.gtf, genome1_unzip)

    ref_fa = file(params.fasta1Unzip, checkIfExists: true)

    transcripts = gffread_transcripts(gff.novel, ref_fa)
    
    translated = transdecoder_process(transcripts)

    filter_by_score(translated.pep, 30, 700)
}
