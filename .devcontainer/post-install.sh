#!/bin/bash

# post-install.sh
# ~~~~~~~~~~~~~~~
# GitHub Codespaces setup for the Ampliseq 16S training environment.

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Ampliseq 16S Training — Codespace Setup                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

###############################################################################
# Update system
###############################################################################

echo "[1/4] Updating system packages..."

apt-get update -qq

apt-get install -y -qq \
    ca-certificates \
    curl \
    wget \
    git \
    openjdk-11-jre-headless \
    > /dev/null 2>&1

###############################################################################
# Install Nextflow
###############################################################################

echo "[2/4] Installing Nextflow..."

if ! command -v nextflow >/dev/null 2>&1; then

    mkdir -p ~/.nextflow/bin

    cd ~/.nextflow/bin

    curl -fsSL https://get.nextflow.io | bash > /dev/null 2>&1

    chmod +x nextflow

    mv nextflow /usr/local/bin/

    cd - >/dev/null

    echo "✓ Nextflow installed: $(nextflow -version 2>&1 | head -1)"

else

    echo "✓ Nextflow already installed"

fi

###############################################################################
# Pre-warm nf-core/ampliseq pipeline cache
###############################################################################
# NOTE: We do NOT git clone this to a fixed path anymore. main.sh runs
# `nextflow run nf-core/ampliseq -r 2.18.0`, and Nextflow resolves that
# by name from its own asset cache (~/.nextflow/assets/). Pulling here
# just warms that cache ahead of time so the live demo doesn't stall on
# a first-time download. Version pinned to 2.18.0 to match main.sh —
# older releases (like 2.10.0) fail to parse on newer Nextflow versions
# due to a strict-syntax config incompatibility.

echo "[3/4] Pre-downloading nf-core/ampliseq (v2.18.0)..."

if ! nextflow list 2>/dev/null | grep -q "nf-core/ampliseq"; then

    nextflow pull nf-core/ampliseq -r 2.18.0 > /dev/null 2>&1

    echo "✓ Ampliseq pipeline cached"

else

    echo "✓ Ampliseq pipeline already cached"

fi

###############################################################################
# Verify installation
###############################################################################

echo "[4/4] Verifying installation..."

echo "✓ Nextflow: $(nextflow -version 2>&1 | head -1)"
echo "✓ Java: $(java -version 2>&1 | head -1)"

if command -v docker >/dev/null 2>&1; then
    echo "✓ Docker: $(docker --version 2>&1)"
else
    echo "⚠ Docker not found yet — the docker-in-docker devcontainer feature"
    echo "  may still be starting. It should be ready by the time you run"
    echo "  'bash main.sh'; if not, reload the Codespace window."
fi

###############################################################################
# Finished
###############################################################################

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ Setup complete!"
echo ""
echo "Run the practical with:"
echo ""
echo "    bash main.sh"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""