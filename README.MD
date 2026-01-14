# Documentation

**For comprehensive documentation, please see [README.md](README.md)**

**For a quick start guide, see [QUICKSTART.md](QUICKSTART.md)**

## Quick Reference

### Basic Run
```bash
nextflow run main.nf -profile standard
```

### Resume Interrupted Run
```bash
nextflow run main.nf -profile standard -resume
```

## Prerequisites

### Build Comet Search Docker Image (Optional)
If using mass spectrometry search functionality:
```bash
cd images
docker build -t comet:2025.03 .
```

## Running in Background

To run the workflow in the background using screen:

1. Create a new screen: `screen -S nf_run`
2. Enter it: `screen -r nf_run`
3. Run your command: `nextflow run main.nf -profile standard`
4. To exit without killing the screen: Press `Ctrl + A` then `d`
5. To reattach later: `screen -r nf_run`