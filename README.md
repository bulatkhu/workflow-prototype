# Novel Transcript Discovery and Protein Prediction Workflow

A Nextflow pipeline for discovering novel transcripts from RNA-seq data, identifying intergenic transcripts, and predicting their protein-coding potential.

## Overview

This workflow integrates RNA-seq analysis with novel transcript discovery to identify previously unannotated transcripts, particularly those located in intergenic regions. The pipeline then predicts protein-coding regions in these novel transcripts, making them ready for downstream proteomics analysis.

### What This Pipeline Does

1. **RNA-seq Alignment & Quantification**: Aligns RNA-seq reads to a reference genome and quantifies known transcripts (can be skipped if a BAM file is provided)
2. **Novel Transcript Assembly**: Assembles transcripts including novel ones using StringTie
3. **Transcript Classification**: Compares novel transcripts against reference annotations to identify intergenic transcripts
4. **Sequence Extraction**: Extracts transcript sequences from the genome
5. **Protein Prediction**: Predicts protein-coding regions using TransDecoder

## Prerequisites

### Software Requirements

- **Nextflow** (version 22.10 or later)
  - Install Java 17 or later by following instructions at https://www.oracle.com/java/technologies/downloads/
  - Install: `curl -s https://get.nextflow.io | bash`
  - Or via conda: `conda install bioconda::nextflow`

- **Docker** (for containerized execution)
  - Install: Follow instructions at https://docs.docker.com/get-docker/

- **nf-core/rnaseq** (automatically pulled by Nextflow)

## Optional Input

- **BAM File**: If a pre-aligned BAM file is available, it can be provided to skip the RNA-seq alignment and quantification step. Specify the BAM file path using the `--bam` parameter.

### Optional: Comet Search Engine

If you plan to use the mass spectrometry search functionality (currently commented out), you'll need to build the Comet Docker image:

```bash
cd images
docker build -t comet:2025.03 .
```

## Quick Start

### 1. Prepare Your Data

#### Input Files Required

- **RNA-seq reads**: FASTQ files (paired-end or single-end)
- **Reference genome FASTA**: Uncompressed genome sequence file
- **Reference genome GTF**: Gene annotation file (uncompressed)
- **Samplesheet**: CSV file describing your samples

#### Directory Structure

Organize your data as follows:

```
workflow-prototype/
├── data/
│   ├── reads/              # Your FASTQ files (*.fastq.gz)
│   ├── reference/          # Reference genome FASTA
│   ├── genome/             # Reference GTF annotation
│   └── samplesheet.csv     # Sample information
└── main.nf
```

#### Samplesheet Format

Create a CSV file (`data/samplesheet.csv`) with the following columns:

```csv
sample,fastq_1,fastq_2,strandedness
THP1_R,/path/to/THP1_R1.fastq.gz,/path/to/THP1_R2.fastq.gz,reverse
THP1_S,/path/to/THP1_S1.fastq.gz,/path/to/THP1_S2.fastq.gz,reverse
```

**Column descriptions:**
- `sample`: Unique sample identifier
- `fastq_1`: Path to forward reads (R1)
- `fastq_2`: Path to reverse reads (R2) - use empty string for single-end
- `strandedness`: RNA-seq library strandedness (`forward`, `reverse`, `unstranded` or `auto`)

### 2. Configure Parameters

Edit `main.nf` or pass parameters via command line. Key parameters:

- `--reads`: Path pattern to FASTQ files (default: `data/reads/*.fastq.gz`)
- `--samplesheet`: Path to samplesheet CSV (default: `data/samplesheet.csv`)
- `--fasta1`: Path to reference genome FASTA (compressed or uncompressed)
- `--genome1`: Path to reference GTF annotation (compressed or uncompressed)
- `--outdir`: Output directory (default: `results`)
- `--bam`: Path to pre-aligned BAM file (optional, skips RNA-seq alignment and quantification if provided)
- `--mode`: StringTie assembly mode (default: `strict`). Valid options:
  - `balanced`: Produces more transcripts but may include more false positives
  - `conservative`: Balanced approach with moderate stringency
  - `strict`: High stringency, fewer transcripts but higher confidence

### 3. Run the Pipeline

#### Basic Run

```bash
nextflow run main.nf -profile standard
```

#### Custom Parameters

```bash
nextflow run main.nf \
  -profile standard \
  --samplesheet data/samplesheet.csv \
  --fasta1 data/reference/Homo_sapiens.GRCh38.dna.toplevel.fa.gz \
  --genome1 data/genome/Homo_sapiens.GRCh38.114.chr.gtf.gz \
  --outdir results
```

#### Resume a Previous Run

If a run was interrupted, resume it with:

```bash
nextflow run main.nf -profile standard -resume
```

#### Run in Background (Recommended for Long Jobs)

```bash
# Create a new screen session
screen -S nf_run

# Run the pipeline
nextflow run main.nf -profile standard

# Detach from screen: Press Ctrl+A, then D
# Reattach later: screen -r nf_run
```

## Workflow Steps Explained

### Step 1: RNA-seq Analysis (`rnaseq_wrapper`)

- **Tool**: nf-core/rnaseq pipeline
- **What it does**: 
  - Quality control and trimming of reads
  - Alignment to reference genome using STAR
  - Transcript quantification using Salmon
  - Optional StringTie assembly
  - MultiQC report generation for quality assessment
- **Output**: 
  - Aligned BAM files (sorted)
  - Quantification files
  - **MultiQC report** (`multiqc/star_salmon/multiqc_report.html`) - Comprehensive quality control report

### Step 2: Novel Transcript Assembly (`stringtie_mixed`)

- **Tool**: StringTie
- **What it does**: Assembles transcripts from aligned reads, including novel transcripts not in the reference annotation
- **Output**: GTF file with assembled transcripts

### Step 3: Transcript Comparison (`gffcompare`)

- **Tool**: GFFCompare
- **What it does**: 
  - Compares assembled transcripts against reference annotation
  - Classifies transcripts (known, novel, intergenic, etc.)
  - Identifies intergenic transcripts (class codes: j, i, x, u)
- **Output**: 
  - `novel_transcripts.gtf`: Non-canonical transcripts only
  - `canonical_transcripts.gtf`: All canonical transcripts
  - Comparison statistics and tracking files

### Step 4: Transcript Sequence Extraction (`gffread_transcripts`)

- **Tool**: GFFRead
- **What it does**: Extracts transcript sequences from the genome using the GTF coordinates
- **Output**: FASTA file with transcript sequences

### Step 5: Protein Prediction (`transdecoder_process`)

- **Tool**: TransDecoder
- **What it does**: 
  - Identifies long open reading frames (ORFs)
  - Predicts coding sequences (CDS)
  - Predicts protein sequences
- **Output**: 
  - `.pep`: Predicted protein sequences
  - `.cds`: Coding sequences
  - `.gff3`: GFF3 annotation of predicted genes
  - `.bed`: BED file with gene locations

## Output Structure

After a successful run, your results will be organized as follows:

```
results/
├── rnaseq/                    # RNA-seq alignment and quantification, if bam file was provided, this part will be missing
│   ├── star_salmon/
│   │   └── *.sorted.bam
│   └── multiqc/
│       └── star_salmon/
│           └── multiqc_report.html  # Quality control report
├── novel/
│   ├── stringtie_mixed/       # Assembled transcripts
│   │   └── *_mixed.transcripts.gtf
│   └── gffcompare/            # Transcript comparison results
│       ├── novel_transcripts.gtf
│       ├── canonical_transcripts.gtf
│       ├── compare_denovo.annotated.gtf
│       └── compare_denovo.stats
├── gffread/                   # Extracted transcript sequences
│   └── transcripts.fa
└── transdecoder/              # Predicted proteins
    ├── *.transdecoder.pep
    ├── *.transdecoder.cds
    ├── *.transdecoder.gff3
    └── *.transdecoder.bed
```

## Understanding Transcript Class Codes

GFFCompare assigns class codes to transcripts based on their relationship to reference annotations:

- **`=`**: Complete match with reference transcript
- **`c`**: Contained in reference transcript
- **`j`**: Potentially novel isoform (fragment)
- **`i`**: Intron retention
- **`x`**: Exonic overlap with opposite strand
- **`u`**: Intergenic transcript (completely novel)
- **`o`**: Generic overlap with reference
- **`s`**: Intron match on opposite strand

This pipeline focuses on class codes **j, i, x, u** as novel intergenic transcripts.

## Configuration Profiles

### Standard Profile (Local Execution)

Uses Docker containers and runs on your local machine:

```bash
nextflow run main.nf -profile standard
```

**Resource settings** (can be modified in `nextflow.config`):
- CPUs: 12
- Memory: 18 GB

## Troubleshooting

### Common Issues

1. **Docker not found**
   - Ensure Docker is installed and running: `docker ps`
   - Check that your user has Docker permissions

2. **Out of memory errors**
   - Reduce the number of CPUs or increase available memory
   - Edit `nextflow.config` to adjust resource limits

3. **File not found errors**
   - Verify all input file paths are correct
   - Check that files exist and are readable
   - Ensure samplesheet paths are absolute or relative to the project directory

4. **nf-core/rnaseq errors**
   - Check that your reference genome and GTF files are compatible
   - Verify the GTF file is properly formatted
   - Ensure strandedness parameter matches your library preparation

### Getting Help

- Check Nextflow logs: `.nextflow.log`
- Check process-specific logs in `work/` directory
- Review nf-core/rnaseq documentation: https://nf-co.re/rnaseq

## Advanced Usage

### Custom Reference Genomes

To use a different reference genome:

1. Download the FASTA and GTF files for your organism
2. Update paths in `main.nf` or pass via command line:
   ```bash
   nextflow run main.nf \
     --fasta1 /path/to/genome.fa.gz \
     --genome1 /path/to/annotation.gtf.gz
   ```

### Modifying Transcript Filters

To change which transcripts are considered "novel intergenic", edit the `gffcompare` process in `modules/gffcompare.nf`:

```bash
# Current filter (class codes j, i, x, u):
awk '$0 ~ /class_code "(j|i|x|u)"/' compare_denovo.annotated.gtf > novel_transcripts.gtf

# To include only completely novel (u):
awk '$0 ~ /class_code "u"/' compare_denovo.annotated.gtf > canonical_transcripts.gtf
```

### Enabling Mass Spectrometry Search

The Comet search functionality is currently commented out. To enable it:

1. Build the Comet Docker image (see Prerequisites)
2. Uncomment the relevant sections in `main.nf`
3. Provide mass spectrometry data files (`--msraw` parameter)

## Citation

If you use this workflow, please cite:

- **Nextflow**: P. Di Tommaso, et al. Nextflow enables reproducible computational workflows. Nature Biotechnology 35, 316–319 (2017) doi:10.1038/nbt.3820
- **nf-core/rnaseq**: 
    Ewels PA, Peltzer A, Fillinger S, Patel H, Alneberg J, Wilm A, Garcia MU, Di Tommaso P, Nahnsen S. The nf-core framework for community-curated bioinformatics pipelines. Nat Biotechnol. 2020 Mar;38(3):276-278. doi: 10.1038/s41587-020-0439-x. PubMed PMID: 32055031.
- **StringTie**: Pertea M, Pertea GM, Antonescu CM, Chang TC, Mendell JT, Salzberg SL. 2015. StringTie enables improved reconstruction of a transcriptome from RNA-seq reads. Nature Biotechnology 33(3):290–295. doi:10.1038/nbt.3122.
- **GFFCompare**: Pertea G, Pertea M. 2020. GFF Utilities: GffRead and GffCompare. F1000Research 9:304 (ISCB Comm J). doi:10.12688/f1000research.23297.2.
- **TransDecoder**: https://github.com/TransDecoder/TransDecoder

## License

MIT License

Copyright (c) 2026 Bulat Zahner.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
