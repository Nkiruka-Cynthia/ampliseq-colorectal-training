# ampliseq-colorectal-training

<div align="center">

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Nkiruka-Cynthia/ampliseq-colorectal-training)
[![nf-core](https://img.shields.io/badge/nf--core-ampliseq%202.10.0-brightgreen)](https://nf-co.re/ampliseq)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A526.04-blue)](https://www.nextflow.io/)
[![Docker](https://img.shields.io/badge/container-Docker-2496ED)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**A hands-on 16S microbiome practical for the STaiMIC Nextflow Training Program**  
*From raw 16S reads to colorectal cancer microbiome profiles - powered by nf-core/ampliseq 2.10.0*

---

[Open in Codespaces](#-quick-start) · [Biological Story](#-biological-story) · [Results Guide](#️-understanding-your-results)

</div>

---

## What is this?

This repository is the **hands-on practical component** of the STaiMIC Nextflow Bioinformatics Training Program (Session 3, [Date]). It runs the full [nf-core/ampliseq](https://nf-co.re/ampliseq) pipeline for 16S rRNA gene amplicon sequencing analysis.

Learn how to:
- Parse amplicon sequencing metadata into Nextflow channels
- Quality-control raw 16S reads with FastQC
- Remove primer sequences with Cutadapt
- Infer Amplicon Sequence Variants (ASVs) with DADA2
- Assign taxonomy using SILVA reference database
- Calculate alpha/beta diversity and generate microbiome profiles

No local installation needed. No HPC required. One command runs everything.

```bash
bash main.sh
```

---

## Biological Story

We analyse **four 16S samples from two patient groups** — a design that lets us demonstrate both healthy microbiota and disease-associated dysbiosis in a single pipeline run.

| Sample | Patient | Status | Clinical Question |
|--------|---------|--------|-------------------|
| `healthy_1` | Control 1 | Healthy (0) | What taxa dominate a healthy gut microbiota? |
| `healthy_2` | Control 2 | Healthy (0) | Are healthy microbiota reproducible across individuals? |
| `crc_patient_1` | CRC Patient 1 | Disease (1) | Which taxa are depleted/enriched in colorectal cancer? |
| `crc_patient_2` | CRC Patient 2 | Disease (1) | How does CRC microbiome differ from healthy controls? |

> **Why does this design matter?**  
> By comparing `status=0` (healthy) with `status=1` (CRC disease), ampliseq runs **comparative microbiome analysis** — showing both alpha diversity (within-sample richness) and beta diversity (between-sample differences) to highlight disease-associated dysbiosis in real time.

---

## Pipeline Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    nf-core/ampliseq 2.10.0                     │
│              16S Microbiome Profiling Workflow                 │
└────────────────────────────────────────────────────────────────┘

  FASTQ reads (4 samples, paired-end)
       │
       ▼
   ┌─────────┐
   │  FASTQC │  ──▶  Per-read quality metrics
   └─────────┘
       │
       ▼
   ┌──────────────┐
   │  Cutadapt    │  ──▶  Remove 16S primers (V4 region)
   └──────────────┘        Output: trimmed FASTQ
       │
       ▼
   ┌──────────────────┐
   │  DADA2 Denoising │  ──▶  Infer Amplicon Sequence Variants
   └──────────────────┘        Output: ASV table + sequences
       │
       ▼
   ┌──────────────────┐
   │  Taxonomy via    │  ──▶  Assign taxonomy to each ASV
   │  DADA2 + SILVA   │        Output: feature × taxa table
   └──────────────────┘
       │
       ├──────────────────────────────────┐
       ▼                                  ▼
   ┌──────────────────┐        ┌───────────────────┐
   │  Alpha Diversity │        │  Beta Diversity   │
   │  (Richness)      │        │  (Community diff) │
   │  - Shannon index │        │  - Bray-Curtis   │
   │  - Chao1 index   │        │  - PCoA plots    │
   │  - Rarefaction   │        │  - PERMANOVA      │
   └──────────────────┘        └───────────────────┘
       │                                  │
       └──────────────┬───────────────────┘
                      ▼
              ┌──────────────┐
              │  MultiQC     │  ──▶  QC report + diversity summary
              └──────────────┘
              ┌──────────────┐
              │ Phyloseq /   │  ──▶  R objects for downstream analysis
              │ TreeSE       │
              └──────────────┘

    Output: feature table, taxa profiles, diversity indices, 
            abundance plots, MultiQC report
```

---

## Quick Start

### Step 1 — Open in GitHub Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Nkiruka-Cynthia/ampliseq-colorectal-training)

Click the badge above or navigate to:
```
Code → Codespaces → Create codespace on main
```

Wait ~3 minutes for the environment to set up automatically. You will see:
```
✅ Setup complete! You are ready to run: bash main.sh
```

### Step 2 — Understand the samplesheet (2–3 min)

```bash
nextflow run course/01_samplesheet.nf
```

### Step 3 — Explore pipeline concepts (optional, instant)

```bash
nextflow run course/02_primer_trimming.nf        # Cutadapt concepts
nextflow run course/03_asv_inference.nf          # DADA2 ASV concepts  
nextflow run course/04_taxonomy_assignment.nf    # Taxonomic classification
```

### Step 4 — Run the full pipeline (~25 min)

```bash
bash main.sh
```

### Step 5 — Explore results

```bash
# View all output directories
ls results/

# Inspect the ASV table (feature × sample matrix)
cat results/abundance_tables/feature_table.tsv | head -20

# View taxonomic assignments
cat results/abundance_tables/taxonomy.tsv | head -20

# Check alpha diversity metrics
cat results/diversity_analysis/alpha_diversity.tsv

# Open QC report (VS Code → right-click → Open with Live Server)
results/multiqc/multiqc_report.html
```

---

## Repository Structure

```
ampliseq-colorectal-training/
│
├──  README.md                    This file
├──  GETTING_STARTED.md           Detailed student setup guide
├──  main.sh                      ← STUDENTS RUN THIS
├──  nextflow.config              Pipeline configuration
│
├── data/
│   └── samplesheet.csv           4 × 16S samples (2 healthy, 2 CRC)
│
├── course/
│   ├── 01_samplesheet.nf         Lesson 1: samplesheet structure
│   ├── 02_primer_trimming.nf     Lesson 2: Cutadapt QC concepts
│   ├── 03_asv_inference.nf       Lesson 3: DADA2 ASV generation
│   ├── 04_taxonomy_assignment.nf Lesson 4: taxonomy classification
│   └── REFERENCE.md              Nextflow + Ampliseq syntax quick-ref
│
├── examples/
│   ├── feature_table.tsv         Example ASV abundance table
│   ├── taxonomy.tsv              Example taxonomic assignments
│   └── diversity_summary.html     Example diversity analysis output
│
└── .devcontainer/
    ├── devcontainer.json         Codespaces environment config
    └── post-install.sh           Auto-setup: Nextflow + Ampliseq + test FASTQs
```

---

## Understanding Your Results

After `bash main.sh` completes, your `results/` folder will contain:

```
results/
├── multiqc/
│   └── multiqc_report.html          START HERE — single QC dashboard
│
├── quality_control/
│   ├── fastqc/                      Per-sample FASTQC reports
│   ├── cutadapt/                    Primer trimming statistics
│   └── dada2/                       DADA2 denoising logs
│
├── abundance_tables/
│   ├── feature_table.tsv            ASV abundance (samples × ASVs)
│   ├── taxonomy.tsv                 Taxonomic assignments per ASV
│   └── dada2_stats.tsv              DADA2 read counts per sample
│
├── diversity_analysis/
│   ├── alpha_diversity.tsv          Shannon, Chao1 indices
│   ├── beta_diversity/
│   │   ├── bray_curtis_distance.tsv Sample-to-sample distances
│   │   ├── pcoa_plot.html           Interactive PCoA plot
│   │   └── permanova_results.txt    Statistical test for differences
│   └── rarefaction_curves/          Alpha rarefaction plots
│
├── taxonomic_profiles/
│   ├── stacked_barplots/            Abundance by phylum/genus
│   ├── heatmaps/                    Relative abundance heatmaps
│   └── healthy_vs_crc.html          Disease-specific composition
│
├── phyloseq_objects/
│   └── phyloseq.Rdata              R phyloseq object for advanced analysis
│
└── pipeline_info/
    ├── timeline.html                Task execution timeline
    ├── report.html                  Resource usage report
    └── trace.txt                    Per-task resource trace
```

---

## 30-Minute Practical Timeline

| Time | Activity | Command | What to watch |
|------|----------|---------|---------------|
| 0–3 min | Codespace setup | Auto | `✅ Setup complete!` message |
| 3–6 min | Samplesheet lesson | `nextflow run course/01_samplesheet.nf` | 4 samples printed |
| 6–8 min | Launch pipeline | `bash main.sh` | Task list appears |
| 8–25 min | Pipeline running | — | Tasks completing live (trimming → DADA2 → taxonomy) |
| 25–30 min | Explore results + Q&A | `ls results/` | MultiQC report + diversity plots |

---

## Technical Configuration

| Parameter | Value | Reason |
|-----------|-------|--------|
| Ampliseq version | 2.10.0 | Compatible with Nextflow ≥25.10 |
| Region | 16S V4 (default) | Universal bacterial marker gene |
| Taxonomy DB | SILVA 138 | Well-curated reference database |
| Profile | `docker` | Reliable container execution |
| Tools | DADA2 + QIIME2 | Denoising + diversity analysis |
| Resource limit | 2 CPU / 8GB RAM | Codespaces free tier safe |

---

## References

| Tool | Reference |
|------|----------|
| **nf-core/ampliseq** | [Straub et al., Frontiers Microbiology 2020](https://doi.org/10.3389/fmicb.2020.550420) |
| **DADA2** | [Callahan et al., Nat. Methods 2016](https://doi.org/10.1038/nmeth.3869) |
| **QIIME2** | [Bolyen et al., Nat. Biotechnol. 2019](https://doi.org/10.1038/s41587-019-0209-9) |
| **SILVA** | [Quast et al., Nucleic Acids Res. 2013](https://doi.org/10.1093/nar/gks1195) |
| **Nextflow** | [Di Tommaso et al., Nat. Biotechnol. 2017](https://doi.org/10.1038/nbt.3820) |
| **nf-core** | [Ewels et al., Nat. Biotechnol. 2020](https://doi.org/10.1038/s41587-020-0439-x) |

---

## Questions?

See **[GETTING_STARTED.md](GETTING_STARTED.md)** for detailed setup help or refer to the [nf-core/ampliseq documentation](https://nf-co.re/ampliseq).

---

<div align="center">

Built for the **STaiMIC Nextflow Training Program**  
by [Nkiruka Cynthia Efenji](https://github.com/Nkiruka-Cynthia) · Nextflow Ambassador · [@Seqera](https://seqera.io)

</div>
