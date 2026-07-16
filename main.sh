#!/bin/bash
#
# main.sh
# ~~~~~~~
# Single entry script for the complete Ampliseq 16S training pipeline.
# Students run ONE command: bash main.sh
#
# Expected runtime: ~20-25 minutes on a 2-core/8GB GitHub Codespace

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Ampliseq 16S Microbiome Training - Practical Exercise         ║"
echo "║  Complete pipeline: FASTQ → ASVs → Taxonomy → Diversity       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check Nextflow
if ! command -v nextflow &> /dev/null; then
    echo "❌ ERROR: Nextflow not found."
    echo "   Install with: curl -fsSL https://get.nextflow.io | bash"
    exit 1
fi

echo "✓ Nextflow found: $(nextflow -version 2>&1 | head -1)"
echo "✓ Java found: $(java -version 2>&1 | head -1)"
echo "✓ Docker found: $(docker --version 2>&1)"

# Verify Docker daemon is running
if ! docker ps > /dev/null 2>&1; then
    echo "❌ ERROR: Docker daemon is not running."
    echo "   Please start Docker Desktop and try again."
    exit 1
fi
echo "✓ Docker daemon is running"
echo ""

echo "Running Ampliseq 16S microbiome pipeline..."
echo ""
echo "Stages that will run:"
echo "  1. FASTQC       → Quality control on raw 16S reads"
echo "  2. Cutadapt     → Remove forward/reverse primers from reads"
echo "  3. DADA2        → Infer Amplicon Sequence Variants (ASVs)"
echo "  4. Taxonomy     → Assign taxonomy via SILVA database"
echo "  5. Diversity    → Calculate alpha/beta diversity indices"
echo "  6. MultiQC      → Aggregate all QC metrics into one report"
echo ""

# Run Ampliseq using Docker
# Genome and resource limits are set in nextflow.config
nextflow run $HOME/ampliseq \
  -profile docker \
  --input "$REPO_ROOT/data/samplesheet.csv" \
  --outdir "$REPO_ROOT/results" \
  --FW_primer "GTGYCAGCMGCCGCGGTAA" \
  --RV_primer "GGACTACNVGGGTWTCTAAT" \
  --dada_ref_taxonomy "silva=138" \
  -resume

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ Pipeline complete!"
echo ""
echo "Results locations:"
echo "   • QC reports:       results/multiqc/"
echo "   • Feature table:    results/abundance_tables/feature_table.tsv"
echo "   • Taxonomy:         results/abundance_tables/taxonomy.tsv"
echo "   • Diversity:        results/diversity_analysis/"
echo "   • Phyloseq object:  results/phyloseq_objects/"
echo ""
echo "Next steps:"
echo "   1. Open results/multiqc/multiqc_report.html in your browser"
echo "   2. Inspect feature table (ASV abundance):"
echo "      cat results/abundance_tables/feature_table.tsv | head -20"
echo "   3. View taxonomic assignments:"
echo "      cat results/abundance_tables/taxonomy.tsv | head -20"
echo "   4. Check alpha diversity metrics:"
echo "      cat results/diversity_analysis/alpha_diversity.tsv"
echo "   5. Explore beta diversity PCoA plot:"
echo "      results/diversity_analysis/beta_diversity/pcoa_plot.html"
echo "   6. Read course/REFERENCE.md for Nextflow + Ampliseq concepts"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
