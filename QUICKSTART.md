# Quick Start Guide

A condensed guide for getting started quickly.

## Minimum Requirements

- Nextflow installed
- Docker installed and running
- Your RNA-seq data in FASTQ format

## 5-Minute Setup

### 1. Prepare Samplesheet

Create `data/samplesheet.csv`:

```csv
sample,fastq_1,fastq_2,strandedness
Sample1,/absolute/path/to/Sample1_R1.fastq.gz,/absolute/path/to/Sample1_R2.fastq.gz,auto
```

### 2. Prepare Reference Files

Place your reference files:
- Genome FASTA: `data/reference/genome.fa.gz` (or uncompressed)
- GTF annotation: `data/genome/annotation.gtf.gz` (or uncompressed)

### 3. Update Paths in main.nf

Edit these lines in `main.nf` (around lines 24-27):

```nextflow
params.fasta1Unzip  = "data/reference/your_genome.fa"
params.fasta1       = "data/reference/your_genome.fa.gz"
params.genome1      = "data/genome/your_annotation.gtf.gz"
params.genomeUnzip  = "data/genome/your_annotation.gtf"
```

### 4. Run

```bash
nextflow run main.nf -profile standard
```

### 5. Find Results

Check `results/` directory:
- **Quality control report**: `results/rnaseq/multiqc/star_salmon/multiqc_report.html` - Open in browser to view QC metrics
- Novel transcripts: `results/novel/gffcompare/novel_transcripts.gtf`
- Canonical transcripts `results/novel/gffcompare/canonical_transcripts.gtf`
- Predicted proteins: `results/transdecoder/*.pep`

## Common Commands

```bash
# Basic run
nextflow run main.nf -profile standard

# Resume interrupted run
nextflow run main.nf -profile standard -resume

# Run with custom output directory
nextflow run main.nf -profile standard --outdir my_results

# Run in background (screen)
screen -S nf
nextflow run main.nf -profile standard
# Press Ctrl+A then D to detach
# Later: screen -r nf to reattach
```

## What to Expect

- **Runtime**: 2-6 hours per sample (depending on data size)
- **Disk space**: ~100-200 GB per sample
- **Output**: Novel transcripts and predicted proteins in `results/`

## Need Help?

See the full [README.md](README.md) for detailed documentation.
