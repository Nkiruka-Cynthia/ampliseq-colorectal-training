# ampliseq-colorectal-training

<div align="center">

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Nkiruka-Cynthia/ampliseq-colorectal-training)
[![nf-core](https://img.shields.io/badge/nf--core-ampliseq%202.18.0-brightgreen)](https://nf-co.re/ampliseq)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A526.04-blue)](https://www.nextflow.io/)
[![Docker](https://img.shields.io/badge/container-Docker-2496ED)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**A hands-on 16S microbiome practical for the STaiMIC Nextflow Training Program**
*From raw 16S reads to ASVs and taxonomy — powered by nf-core/ampliseq 2.18.0*

---

[Quick Start](#quick-start) · [Biological Story](#biological-story) · [Repository Structure](#repository-structure)

</div>

---

## What is this?

This repository is the **hands-on practical component** of the STaiMIC Nextflow Bioinformatics Training Program (Session 3). It runs the real [nf-core/ampliseq](https://nf-co.re/ampliseq) pipeline for 16S rRNA gene amplicon sequencing analysis.

Learn how to:
- Parse amplicon sequencing metadata into Nextflow channels
- Quality-control raw 16S reads with FastQC
- Remove primer sequences with Cutadapt
- Infer Amplicon Sequence Variants (ASVs) with DADA2
- Assign taxonomy using the SILVA reference database

No local installation needed. No HPC required. One command runs everything:

```bash
bash main.sh
```

For the full step-by-step walkthrough, see **[GETTING_STARTED.md](GETTING_STARTED.md)**. For Nextflow/ampliseq syntax and parameter details, see **[course/REFERENCE.md](course/REFERENCE.md)**.

---

## Biological Story

The teaching narrative for this practical is a small **four-sample colorectal cancer (CRC) vs. healthy gut microbiome** comparison — the kind of design you'd use to explore disease-associated dysbiosis.

| Sample | Group | Status | Clinical Question |
|--------|-------|--------|-------------------|
| `healthy_1` | Control 1 | Healthy (0) | What taxa dominate a healthy gut microbiota? |
| `healthy_2` | Control 2 | Healthy (0) | Are healthy microbiota reproducible across individuals? |
| `crc_patient_1` | CRC Patient 1 | Disease (1) | Which taxa are depleted/enriched in colorectal cancer? |
| `crc_patient_2` | CRC Patient 2 | Disease (1) | How does the CRC microbiome differ from healthy controls? |

This design (`data/samplesheet.csv` + `data/Metadata.tsv`) is what you'd use on **your own real FASTQ data** — see the reference command in `course/REFERENCE.md`.

> ⚠️ **Important:** today's live demo (`bash main.sh`) runs the **official nf-core/ampliseq test dataset**, not these four samples — this avoids downloading gigabytes of FASTQ data during class. The pipeline, parameters, and steps are identical either way; only the input data differs. Don't expect the live run's actual output to show a healthy-vs-CRC biological signal — for that, run the pipeline on real data using the reference command.

---

## Pipeline Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    nf-core/ampliseq 2.18.0                     │
│              16S Microbiome Profiling Workflow                 │
└────────────────────────────────────────────────────────────────┘

  FASTQ reads (paired-end)
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
       ▼
   ┌──────────────┐
   │  MultiQC     │  ──▶  Aggregated QC + summary report
   └──────────────┘
```

QIIME2's secondary analysis branch (classifier training, barplots, alpha/beta diversity, differential abundance) also exists in the pipeline, but is **skipped in the live demo** via `--skip_qiime` — see `main.sh` for why and how to re-enable it outside class time constraints.

---

## Quick Start

```bash
bash main.sh
```

That's it — see **[GETTING_STARTED.md](GETTING_STARTED.md)** for the full setup walkthrough (Codespace setup, optional lessons, exploring results, troubleshooting).

---

## How Input Data Works

Ampliseq needs two separate files: a **samplesheet** (tells it where your FASTQ files are) and a **metadata** file (tells it how to group samples for comparison).

**`data/samplesheet.csv`** — required columns: `sampleID,forwardReads,reverseReads`
```csv
sampleID,forwardReads,reverseReads
healthy_1,data/fastq/healthy_1_1.fastq.gz,data/fastq/healthy_1_2.fastq.gz
healthy_2,data/fastq/healthy_2_1.fastq.gz,data/fastq/healthy_2_2.fastq.gz
crc_patient_1,data/fastq/crc_patient_1_1.fastq.gz,data/fastq/crc_patient_1_2.fastq.gz
crc_patient_2,data/fastq/crc_patient_2_1.fastq.gz,data/fastq/crc_patient_2_2.fastq.gz
```

**`data/Metadata.tsv`** — tab-separated, first column must be `ID` and match `sampleID` exactly:
```tsv
ID	condition	status
healthy_1	healthy	0
healthy_2	healthy	0
crc_patient_1	disease	1
crc_patient_2	disease	1
```

**Running on your OWN data:**
```bash
nextflow run nf-core/ampliseq -r 2.18.0 \
    -profile docker \
    --input data/samplesheet.csv \
    --metadata data/Metadata.tsv \
    --metadata_category status \
    --FW_primer GTGYCAGCMGCCGCGGTAA \
    --RV_primer GGACTACNVGGGTWTCTAAT \
    --dada_ref_taxonomy silva=138 \
    --outdir results
```

**Running today's live demo (official test dataset, class-time-friendly):**
```bash
nextflow run nf-core/ampliseq \
    -r 2.18.0 \
    -profile test,docker \
    --outdir results \
    --skip_qiime \
    -resume
```
(this is exactly what `bash main.sh` runs for you)

Full parameter reference, output file structure, and troubleshooting: **[course/REFERENCE.md](course/REFERENCE.md)**.

---

## Repository Structure

```
ampliseq-colorectal-training/
│
├── README.md                    This file
├── GETTING_STARTED.md           Step-by-step student setup guide
├── main.sh                      ← STUDENTS RUN THIS
├── nextflow.config              Pipeline resource/profile configuration
│
├── data/
│   ├── samplesheet.csv           Teaching example: 4 × 16S samples (2 healthy, 2 CRC)
│   └── Metadata.tsv               Teaching example: sample grouping metadata
│
├── course/
│   ├── 01_samplesheet.nf         Lesson 1: samplesheet + metadata structure
│   ├── 02_primer_trimming.nf     Lesson 2: Cutadapt QC concepts
│   ├── 03_asv_inference.nf       Lesson 3: DADA2 ASV generation
│   ├── 04_taxonomy_assignment.nf Lesson 4: taxonomy classification
│   └── REFERENCE.md              Nextflow + Ampliseq syntax & parameter reference
│
└── .devcontainer/
    ├── devcontainer.json         Codespaces environment config
    └── post-install.sh           Auto-setup: Nextflow + pre-cached ampliseq pipeline
```

---

## Technical Configuration

| Parameter | Value | Reason |
|-----------|-------|--------|
| Ampliseq version | 2.18.0 | Compatible with modern Nextflow (≥26); older releases fail to parse due to a strict-syntax config incompatibility |
| Live demo dataset | Official nf-core/ampliseq test data (`-profile test`) | No multi-GB download needed during class |
| Region | 16S V4 | Universal bacterial marker gene |
| Taxonomy | DADA2's built-in classifier (SILVA) | QIIME2's separate classifier training is skipped for time (see `--skip_qiime` in `main.sh`) |
| Container | Docker | Reliable, reproducible execution |
| Resource limit | 2 CPU / 10GB RAM / 40 min per process | Sized for a 4-core/16GB local laptop or Codespaces; see `nextflow.config` |

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

See **[GETTING_STARTED.md](GETTING_STARTED.md)** for setup help, **[course/REFERENCE.md](course/REFERENCE.md)** for syntax/parameters, or the [nf-core/ampliseq documentation](https://nf-co.re/ampliseq).

---

<div align="center">

Built for the **STaiMIC Nextflow Training Program**
by [Nkiruka Cynthia Efenji](https://github.com/Nkiruka-Cynthia) · Nextflow Ambassador · [@Seqera](https://seqera.io)

</div>