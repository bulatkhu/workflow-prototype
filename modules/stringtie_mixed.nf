params.outdir  = "results"
params.mode = params.mode ?: 'strict' // Default to 'strict' if not specified

// Recommended proteogenomics presets:
//   balanced:      -f 0.1 -c 2.5 // Warning! May produce too many false positives
//   conservative:  -f 0.3 -c 10
//   strict:        -f 0.5 -c 15
def modeParams = [
    balanced: '-f 0.1 -c 2.5',
    conservative: '-f 0.3 -c 10',
    strict: '-f 0.5 -c 15'
]

// Validate the mode
if (!modeParams.containsKey(params.mode)) {
    error "Invalid mode '${params.mode}'. Valid options are: ${modeParams.keySet().join(', ')}"
}

// Get the parameters for the selected mode
def stringtieParams = modeParams[params.mode]

process stringtie_mixed {
    publishDir "${params.outdir}/novel/stringtie_mixed", mode: 'copy'
    container "quay.io/biocontainers/stringtie:3.0.3--h29c0135_0"

    tag "assembling transcripts with novel discovery"

    input:
    val sample_name
    path bam
    path genome

    output:
    path("*.gtf"), emit: gtf
    // path("${meta.sample}_mixed.transcripts.gtf"), emit: gtf
    // path("*.gtf")  // alternative for file name flexibility

    script:
    """
    stringtie ${bam} \
        -G ${genome} \
        --mix \
        ${stringtieParams} \
        -p ${task.cpus} \
        -o ${sample_name}_mixed.transcripts.gtf
    """
}