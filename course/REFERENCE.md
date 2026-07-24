# Nextflow + Ampliseq Quick Reference

## Nextflow DSL 2 Basics

### Workflow structure
```nextflow
nextflow.enable.dsl = 2

params.outdir = "results"

workflow {
    // Main workflow logic here
}
```
Note: don't set `params.input` or pipeline-specific params (like `FW_primer`)
as global defaults in `nextflow.config` if you also want to run `-profile test`
— global param defaults override the test profile's own built-in data.

### Reading the samplesheet + metadata
Ampliseq keeps FASTQ file locations and sample grouping in two separate
files. Here's how you'd read both with plain Nextflow channels:
```nextflow
// samplesheet.csv: sampleID, forwardReads, reverseReads
ch_samples = channel
    .fromPath(params.input, checkIfExists: true)
    .splitCsv(header: true)
    .map { row -> [row.sampleID, file(row.forwardReads), file(row.reverseReads)] }

// Metadata.tsv: ID, condition, status (tab-separated)
ch_metadata = channel
    .fromPath(params.metadata, checkIfExists: true)
    .splitCsv(header: true, sep: '\t')
    .map { row -> [row.ID, row.condition, row.status] }

ch_samples.join(ch_metadata).view()
```

### Running a process
```nextflow
process FASTQC {
    input:
        tuple val(meta), path(fastq1), path(fastq2)
    
    output:
        path("*.html"), emit: html
    
    script:
        """
        fastqc ${fastq1} ${fastq2}
        """
}

workflow {
    ch_input = channel.fromPath(...)
    FASTQC(ch_input)
}
```

### Collecting outputs
```nextflow
ch_samples
    .collect()           // Gather all items into a list
    .view()              // Print the list
```

---

## Ampliseq Parameters

### Required parameters (for real data)
```bash
# Input samplesheet
--input "data/samplesheet.csv"

# Metadata (optional, but needed for grouped diversity comparisons)
--metadata "data/Metadata.tsv"
--metadata_category "status"

# Output directory
--outdir "results"

# 16S primers (V4 shown here)
--FW_primer "GTGYCAGCMGCCGCGGTAA"
--RV_primer "GGACTACNVGGGTWTCTAAT"
```

### Taxonomy databases
```bash
# SILVA — used throughout this training
--dada_ref_taxonomy "silva=138"

# NOTE: as of ampliseq 2.18.0, the pipeline's own DEFAULT changed from
# SILVA to sbdi-gtdb=R11-RS232-1. We pass silva=138 explicitly above so
# this training is unaffected either way.

# RDP
--dada_ref_taxonomy "rdp"

# Custom database
--dada_ref_taxonomy "/path/to/custom_db.fasta"
```

### Quality filtering
```bash
# Minimum sequence frequency (remove rare ASVs)
--min_frequency 10

# Maximum expected error (DADA2 parameter)
--max_ee 3
```

### Output options
```bash
# Skip specific analyses
--skip_diversity_indices true   # Skip alpha/beta diversity
--skip_barplot true              # Skip barplots
```

---

## Samplesheet Format

Ampliseq 2.18.0 requires exactly these column headers (comma, tab, or YAML):

### Required columns:
```
sampleID,forwardReads,reverseReads
```

### Example (`data/samplesheet.csv`):
```csv
sampleID,forwardReads,reverseReads
healthy_1,data/fastq/healthy_1_1.fastq.gz,data/fastq/healthy_1_2.fastq.gz
healthy_2,data/fastq/healthy_2_1.fastq.gz,data/fastq/healthy_2_2.fastq.gz
crc_patient_1,data/fastq/crc_patient_1_1.fastq.gz,data/fastq/crc_patient_1_2.fastq.gz
crc_patient_2,data/fastq/crc_patient_2_1.fastq.gz,data/fastq/crc_patient_2_2.fastq.gz
```

### Column definitions:
- **sampleID**: Unique sample identifier (must start with a letter)
- **forwardReads**: Path to forward reads (R1)
- **reverseReads**: Path to reverse reads (R2)

Grouping info (healthy vs. disease) does NOT go in the samplesheet — it
lives in a separate metadata file (see below).

### Metadata format (`data/Metadata.tsv`)

Metadata follows the QIIME2 spec: tab-separated, first column header
must be `ID` and match `sampleID` exactly.

```tsv
ID	condition	status
healthy_1	healthy	0
healthy_2	healthy	0
crc_patient_1	disease	1
crc_patient_2	disease	1
```

Passed to the pipeline with `--metadata data/Metadata.tsv` and used for
group comparisons with `--metadata_category status`.

---

## Output Directory Structure (real ampliseq 2.18.0 output)

```
results/
├── input/                       # Copy of your samplesheet/metadata
├── summary_report/
│   └── summary_report.html      # Overview report, start here
├── fastqc/                      # Per-sample raw read QC
├── cutadapt/                    # Primer trimming logs + summary
├── multiqc/
│   └── multiqc_report.html      # Aggregated QC dashboard
├── dada2/
│   ├── ASV_seqs.fasta           # ASV sequences
│   ├── ASV_table.tsv            # ASV counts per sample
│   ├── ASV_tax.*.tsv            # Taxonomic classification (DADA2, default)
│   └── DADA2_stats.tsv          # Read tracking through DADA2
├── qiime2/
│   ├── abundance_tables/
│   │   └── feature-table.tsv    # Final abundance table
│   ├── rel_abundance_tables/    # Relative (normalized) abundance
│   ├── barplot/index.html       # Interactive taxa barplot
│   ├── alpha-rarefaction/index.html
│   └── diversity/
│       ├── alpha_diversity/     # Shannon, Faith's PD, evenness, etc.
│       └── beta_diversity/      # Bray-Curtis, Jaccard, UniFrac, PCoA
├── phyloseq/
│   └── <taxonomy>_phyloseq.rds  # R phyloseq object
├── overall_summary.tsv          # Read counts through every pipeline step
└── pipeline_info/
    ├── execution_timeline.html
    ├── execution_report.html
    └── execution_trace.txt
```

---

## Key Output Files

### dada2/ASV_table.tsv (ASV abundance)
Rows = ASVs, columns = samples, values = read counts.

### dada2/ASV_tax.*.tsv (taxonomy)
Tab-separated taxonomic classification per ASV, columns typically
include Kingdom, Phylum, Class, Order, Family, Genus, Species.

### qiime2/diversity/alpha_diversity/shannon_vector/index.html
Interactive Shannon diversity index per sample (open in browser).

### qiime2/diversity/beta_diversity/bray_curtis_distance_matrix.tsv
Pairwise Bray-Curtis distances between samples.

💡 Exact filenames can vary slightly depending on which taxonomy
classifier and options are active — check `results/summary_report/summary_report.html`
first, it links to everything else.

---

## Common Commands

### Run today's live demo (official nf-core test dataset)
```bash
bash main.sh
```

### Run on your OWN data
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

### Run a specific lesson
```bash
nextflow run course/01_samplesheet.nf
```

### Resume interrupted run
```bash
bash main.sh
# Nextflow caches intermediate results; -resume picks up where it left off
```

### View results
```bash
# Browse the summary report first
open results/summary_report/summary_report.html

# Browse QC report
open results/multiqc/multiqc_report.html

# View the ASV table
head -20 results/dada2/ASV_table.tsv

# Check read-count tracking across the whole pipeline
cat results/overall_summary.tsv
```

---

## Troubleshooting

### Pipeline fails with "Docker daemon not running"
→ Start Docker Desktop

### Nextflow not found
→ Install: `curl -fsSL https://get.nextflow.io | bash`

### Config parsing error mentioning `check_max` or "Unexpected input"
→ Your Nextflow version is too new for an old pipeline release's config
  syntax. Use `-r 2.18.0` (or later) with nf-core/ampliseq — this training
  is pinned to 2.18.0 for exactly this reason.

### Out of memory
→ Reduce `resourceLimits` in `nextflow.config`, or run on a machine/VM
  with more RAM allocated to Docker/WSL

### Samplesheet validation fails
→ Check column headers are exactly `sampleID,forwardReads,reverseReads`
→ Verify file paths exist
→ Sample IDs must start with a letter, no dashes or dots

---

## Further Reading

- **nf-core/ampliseq**: https://nf-co.re/ampliseq
- **DADA2 paper**: https://doi.org/10.1038/nmeth.3869
- **Nextflow docs**: https://www.nextflow.io/docs/latest/
- **QIIME2 diversity**: https://docs.qiime2.org/