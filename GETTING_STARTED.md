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
nextflow run course/01_samplesheet.nf      # Understand the samplesheet + metadata
nextflow run course/02_primer_trimming.nf  # QC and primer removal concepts
nextflow run course/03_asv_inference.nf    # DADA2 ASV inference concepts
nextflow run course/04_taxonomy_assignment.nf  # Taxonomic classification
```

---

## Step 3 — Run the Full Pipeline

```bash
bash main.sh
```

This runs the OFFICIAL nf-core/ampliseq test dataset (same pipeline, same
steps you'd use on real data) — expected runtime: roughly 30 minutes on
a 2-core/8GB Codespace, plus extra time on the very first run while
Nextflow downloads the pipeline code, Docker images, and test data.
Pipeline completed successfully = done.

Note: QIIME2's diversity analysis, barplots, and classifier training are
intentionally skipped (`--skip_qiime` in `main.sh`) to keep the live demo
inside a class-friendly time window — see the comment above that line in
`main.sh` for how to re-enable it later, outside class time constraints.

To run this on YOUR OWN data instead, see the reference command in
`course/REFERENCE.md` or printed at the top of `main.sh`'s output.

---

## Step 4 — Explore Results

```bash
# Start here — overview report with links to everything
open results/summary_report/summary_report.html

# QC report — open in browser
open results/multiqc/multiqc_report.html

# ASV abundance table
cat results/dada2/ASV_table.tsv | head -20

# Taxonomic assignments (DADA2's own classifier — QIIME2 taxonomy is skipped)
cat results/dada2/ASV_tax.*.tsv | head -20

# Read-count tracking across every pipeline step
cat results/overall_summary.tsv
```

💡 QIIME2 diversity plots (alpha/beta diversity, barplots) are not
generated in this run since `--skip_qiime` is set in `main.sh` for time.
Remove that flag (see the comment above it in `main.sh`) to generate
them — budget significant extra runtime if you do.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| nextflow: command not found | Run: `bash .devcontainer/post-install.sh` |
| Config error mentioning `check_max` or "Unexpected input" | Your Nextflow version is too new for the pipeline release being used — this training is pinned to `-r 2.18.0` specifically to avoid this |
| Samplesheet validation failed | Check `data/samplesheet.csv` uses exactly `sampleID,forwardReads,reverseReads` as headers |
| Pipeline fails mid-run | Re-run `bash main.sh` — `-resume` restarts where it stopped |
| Stuck for 30+ min on a QIIME2 step | Check `main.sh` still has `--skip_qiime` set — that step is very slow and shouldn't be running in the live-demo config |
| Out of memory | Upgrade Codespace to 4-core in GitHub settings, or increase Docker/WSL memory allocation |
| Docker daemon not running | Start Docker Desktop and try again |
| WSL won't start / virtualisation error | Check `.wslconfig` processor count matches your CPU, and that virtualization (VT-x) is enabled in BIOS |

---

## Further Reading

- nf-core/ampliseq docs: https://nf-co.re/ampliseq
- DADA2 documentation: https://benjjneb.github.io/dada2/
- QIIME2 documentation: https://docs.qiime2.org/
- Nextflow docs: https://www.nextflow.io/docs/latest/
- Syntax quick-ref: course/REFERENCE.md