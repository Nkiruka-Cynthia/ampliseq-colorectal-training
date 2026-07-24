#!/bin/bash
#
# main.sh
# ~~~~~~~
# Single entry script for the Ampliseq 16S training pipeline.
# Students only need to run:
#
#     bash main.sh
#
# This runs the OFFICIAL nf-core/ampliseq test dataset — same pipeline,
# same parameters, same workflow you'd use on real data, just without
# needing to download gigabytes of FASTQ files during a live class.
#
# The samplesheet.csv and Metadata.tsv in data/ are teaching examples
# only — they show you the exact file structure ampliseq expects for
# YOUR OWN data. See README.md for the full command you'd run against
# real files.

set -e

###############################################################################
# Repository location
###############################################################################

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

###############################################################################
# Banner
###############################################################################

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║          Ampliseq 16S Microbiome Training                            ║"
echo "║                                                                        ║"
echo "║     FASTQ → ASVs → Taxonomy → Diversity Analysis                      ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

###############################################################################
# Check software
###############################################################################

echo "Checking required software..."
echo ""

if ! command -v nextflow >/dev/null 2>&1; then
    echo "❌ ERROR: Nextflow is not installed."
    echo ""
    echo "Install it with:"
    echo "curl -fsSL https://get.nextflow.io | bash"
    exit 1
fi

echo "✓ Nextflow version:"
nextflow -version 2>&1 | head -1

echo "✓ Java:"
java -version 2>&1 | head -1

if ! command -v docker >/dev/null 2>&1; then
    echo ""
    echo "❌ ERROR: Docker is not installed."
    exit 1
fi

echo "✓ Docker:"
docker --version

###############################################################################
# Check Docker daemon
###############################################################################

echo ""

if ! docker ps >/dev/null 2>&1; then
    echo "❌ ERROR: Docker daemon is not running."
    echo ""
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo "✓ Docker daemon is running"

###############################################################################
# Check internet connection
###############################################################################

echo ""
echo "Checking internet connection..."

if ! curl -Is https://github.com >/dev/null 2>&1; then
    echo "❌ ERROR: Internet connection unavailable."
    echo ""
    echo "Nextflow needs internet access the first time it downloads"
    echo "the nf-core/ampliseq pipeline and its official test data."
    exit 1
fi

echo "✓ Internet connection available"

###############################################################################
# What you'd run on YOUR OWN data (reference only — not executed here)
###############################################################################

echo ""
echo "────────────────────────────────────────────────────────────────────"
echo "  Reference: this is the command you'd run on your OWN FASTQ data"
echo "  (see data/samplesheet.csv and data/Metadata.tsv for file format)"
echo "────────────────────────────────────────────────────────────────────"
echo ""
echo '  nextflow run nf-core/ampliseq -r 2.18.0 \'
echo '      -profile docker \'
echo '      --input data/samplesheet.csv \'
echo '      --metadata data/Metadata.tsv \'
echo '      --metadata_category status \'
echo '      --FW_primer GTGYCAGCMGCCGCGGTAA \'
echo '      --RV_primer GGACTACNVGGGTWTCTAAT \'
echo '      --dada_ref_taxonomy silva=138 \'
echo '      --outdir results'
echo ""
echo "────────────────────────────────────────────────────────────────────"
echo "  Today's live run uses the official nf-core/ampliseq test dataset"
echo "  instead — same pipeline, same steps, no multi-GB download needed."
echo "────────────────────────────────────────────────────────────────────"
echo ""

###############################################################################
# Display pipeline overview
###############################################################################

echo "Pipeline to be executed:"
echo ""
echo "  1. FASTQC                 Assess raw read quality"
echo "  2. Cutadapt               Remove primer sequences"
echo "  3. DADA2                  Infer Amplicon Sequence Variants (ASVs)"
echo "  4. Taxonomic Assignment   DADA2's built-in classifier (SILVA)"
echo "  5. MultiQC                Aggregate quality reports"
echo ""
echo "  NOTE: QIIME2 secondary analysis (diversity indices, barplots,"
echo "  differential abundance) is SKIPPED for today's live demo — see"
echo "  the --skip_qiime2 note just above the pipeline call below."
echo ""
echo "Pipeline starting..."
echo ""

###############################################################################
# Run nf-core/ampliseq on the OFFICIAL test dataset
###############################################################################
#
# --skip_qiime TOGGLE
# ~~~~~~~~~~~~~~~~~~~~
# QIIME2_EXTRACT / QIIME2_TRAIN (training a taxonomy classifier from
# scratch against the reference database) is one of the heaviest steps
# in the whole pipeline — it can run well past an hour on modest local
# hardware, even on the tiny official test dataset. That's incompatible
# with a 45-60 min live class window.
#
# --skip_qiime skips ALL QIIME2 secondary analysis for the live demo:
# classifier training, barplots, alpha/beta diversity, differential
# abundance testing. DADA2's OWN taxonomy classification (the default,
# using SILVA) still runs — so Lesson 4's taxonomy story is untouched.
#
# TO RUN THE FULL PIPELINE (with QIIME2 diversity analysis) OUTSIDE
# CLASS TIME CONSTRAINTS: comment out the --skip_qiime line below, and
# either raise nextflow.config's process time limit well above 40.min,
# or run overnight / on a beefier machine. Budget 1-2+ hours extra.

nextflow run nf-core/ampliseq \
    -r 2.18.0 \
    -profile test,docker \
    --outdir results \
    --skip_qiime \
    -resume

###############################################################################
# Finished
###############################################################################

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "🎉 Pipeline completed successfully!"
echo "════════════════════════════════════════════════════════════════════"
echo ""

echo "Output directory:"
echo "   results/"
echo ""

echo "Key outputs:"
echo ""
echo "✓ MultiQC report          results/multiqc/"
echo "✓ Pipeline information    results/pipeline_info/"
echo "✓ ASV abundance tables    results/dada2/ASV_table.tsv"
echo "✓ Taxonomic assignments   results/dada2/ASV_tax.*.tsv"
echo ""
echo "  (QIIME2 diversity analysis was skipped for the live demo —"
echo "   see the --skip_qiime2 note in this script to run it later.)"
echo ""

echo "Next steps:"
echo ""
echo "1. Open the MultiQC report."
echo "2. Inspect the ASV abundance table."
echo "3. Explore taxonomic assignments."
echo "4. Continue with the exercises in course/REFERENCE.md"
echo ""
echo "5. To run this on YOUR OWN data, use the reference command shown"
echo "   above, replacing data/samplesheet.csv and data/Metadata.tsv"
echo "   with your real sample sheet and metadata."
echo ""
echo "6. To include QIIME2 diversity analysis (skipped above for time),"
echo "   see the --skip_qiime toggle note just above the pipeline call"
echo "   in this script."
echo ""

echo "Happy analysing!"
echo ""