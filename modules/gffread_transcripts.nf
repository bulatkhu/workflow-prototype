params.outdir  = "results"


process gffread_transcripts {
    publishDir "${params.outdir}/gffread", mode: 'copy'
    container "biodepot/gffread:65eb9ae8__8fdddb8f__c4ced399"
   
    input:
        path gtf_file
        path ref_fa

    output:
        path "transcripts.fa"

    script:
        """
        gunzip -c ${ref_fa} > unzipped.fasta
        gffread ${gtf_file} -g unzipped.fasta -w transcripts.fa
        """
}