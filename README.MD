To start the script:
---
nextflow run test1.nf
---
nextflow run main.nf   -profile standard   --reads 'data/reads/*.fastq.gz'   --msraw 'data/ms/*.raw'   --fasta 'data/reference/proteome.fasta'   -resume


nextflow run main.nf \
  -profile standard \
  --reads 'data/reads/*.fasta' \
  --msraw 'data/ms/*.mzML' \
  --fasta 'data/reference/proteome.fasta' \
  -resume
