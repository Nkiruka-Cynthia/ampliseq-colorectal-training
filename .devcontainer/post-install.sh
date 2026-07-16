#!/bin/bash

# post-install.sh — Ampliseq training environment setup
# Runs automatically in GitHub Codespaces

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Ampliseq 16S Training — Codespace Setup                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Update system
echo "[1/5] Updating system packages..."
apt-get update -qq
apt-get install -y -qq ca-certificates curl wget git openjdk-11-jre-headless > /dev/null 2>&1

# Install Nextflow
echo "[2/5] Installing Nextflow..."
if ! command -v nextflow &> /dev/null; then
    mkdir -p ~/.nextflow/bin
    cd ~/.nextflow/bin
    curl -fsSL https://get.nextflow.io | bash > /dev/null 2>&1
    chmod +x nextflow
    mv nextflow /usr/local/bin/
    cd - > /dev/null
    echo "✓ Nextflow installed: $(nextflow -version 2>&1 | head -1)"
else
    echo "✓ Nextflow already installed"
fi

# Install/pull ampliseq pipeline
echo "[3/5] Downloading nf-core/ampliseq..."
mkdir -p ~
if [ ! -d "$HOME/ampliseq" ]; then
    nextflow pull nf-core/ampliseq -r 2.10.0 > /dev/null 2>&1
    echo "✓ Ampliseq pipeline ready"
else
    echo "✓ Ampliseq pipeline already present"
fi

# Create test FASTQ files (minimal, for demo purposes)
echo "[4/5] Creating test data..."
mkdir -p data/fastq
if [ ! -f "data/fastq/test_1.fastq.gz" ]; then
    # Create minimal gzipped FASTQ files for testing
    echo -e "@test_seq_1\nGTGYCAGCMGCCGCGGTAACCACCCACACCCGATACGGATACCCACGGGAAAACTGGAAAC\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII" | gzip > data/fastq/test_1.fastq.gz
    echo -e "@test_seq_1\nGATTAGATACCCTGGTAGTCCACGCCGTAAACAATGTAAGTGCTACCTTGGGTACACATGGCAG\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII" | gzip > data/fastq/test_2.fastq.gz
    echo -e "@test_seq_2\nGTGYCAGCMGCCGCGGTAGCCACCCACACCCGATACGGATACCCACGGGAAAACTGGAGACA\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII" | gzip >> data/fastq/test_1.fastq.gz
    echo -e "@test_seq_2\nGATTAGATACCCTGGTAGTCCACGCCGTAAACAATGTAAGTGCTACCTTGGGTACACATGGCCG\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII" | gzip >> data/fastq/test_2.fastq.gz
    
    cp data/fastq/test_1.fastq.gz data/fastq/test2_1.fastq.gz
    cp data/fastq/test_2.fastq.gz data/fastq/test2_2.fastq.gz
    echo "✓ Test FASTQ files created"
else
    echo "✓ Test FASTQ files already exist"
fi

# Verify setup
echo "[5/5] Verifying installation..."
echo "✓ Nextflow: $(nextflow -version 2>&1 | head -1)"
echo "✓ Java: $(java -version 2>&1 | head -1)"
echo "✓ Docker: $(docker --version 2>&1)"
echo "✓ Test data: $(ls -lh data/fastq/*.gz 2>/dev/null | wc -l) files"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ Setup complete! You are ready to run: bash main.sh"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
