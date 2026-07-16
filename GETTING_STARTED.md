# Getting Started

## Step 1 — Open Codespace

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Nkiruka-Cynthia/ampliseq-colorectal-training)

Or: **Code → Codespaces → Create codespace on main**

Wait ~3 minutes. Setup is automatic. You will see:
```
✅ Setup complete! You are ready to run: bash main.sh
```

---

## Step 2 — Run the Lessons (optional, instant to 3 min each)

```bash
nextflow run course/01_samplesheet.nf      # Understand the samplesheet
nextflow run course/02_primer_trimming.nf  # QC and primer removal concepts
nextflow run course/03_asv_inference.nf    # DADA2 ASV inference concepts
nextflow run course/04_taxonomy_assignment.nf  # Taxonomic classification
```

---

## Step 3 — Run the Full Pipeline

```bash
bash main.sh
```

Expected runtime: ~25 minutes. Pipeline completed successfully = done.

---

## Step 4 — Explore Results

```bash
# QC report — open in browser
results/multiqc/multiqc_report.html

# ASV feature table (abundance matrix)
cat results/abundance_tables/feature_table.tsv | head -20

# Taxonomic assignments
cat results/abundance_tables/taxonomy.tsv | head -20

# Alpha diversity metrics
cat results/diversity_analysis/alpha_diversity.tsv

# Beta diversity (sample-to-sample distances)
cat results/diversity_analysis/beta_diversity/bray_curtis_distance.tsv

# Example diversity plots
results/diversity_analysis/beta_diversity/pcoa_plot.html
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| nextflow: command not found | Run: bash .devcontainer/post-install.sh |
| Cannot find ~/ampliseq-latest | Run: bash .devcontainer/post-install.sh |
| Samplesheet validation failed | Check data/samplesheet.csv format; run: bash .devcontainer/post-install.sh |
| Pipeline fails mid-run | Re-run bash main.sh — `-resume` restarts where it stopped |
| Out of memory | Upgrade Codespace to 4-core in GitHub settings |
| Docker daemon not running | Start Docker Desktop and try again |

---

## Further Reading

- nf-core/ampliseq docs: https://nf-co.re/ampliseq
- DADA2 documentation: https://benjjneb.github.io/dada2/
- QIIME2 documentation: https://docs.qiime2.org/
- Nextflow docs: https://www.nextflow.io/docs/latest/
- Syntax quick-ref: course/REFERENCE.md
