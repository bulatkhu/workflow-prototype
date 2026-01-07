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


nextflow run main.nf

nextflow run main.nf   -profile standard   --reads 'data/reads/*.fasta'   --msraw 'data/ms/*.mzML'   --fasta 'data/reference/proteome.fasta' -resume -c pipeline.config

DAG of this workflow: 
![SVG Image](./media/dag.svg)

Prequisits: 
build comet search docker image: 
"cd images"
"docker build -t comet:2025.03 ."

To run workflow in background:
create a new screen:  screen -S nf_run
enter it:             screen -r nf_run
if you want to exit without killing the screen, first press Ctrl + A then d