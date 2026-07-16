# Nextflow + Ampliseq Quick Reference

## Nextflow DSL 2 Basics

### Workflow structure
```nextflow
nextflow.enable.dsl = 2

params {
    input = "data/samplesheet.csv"
    outdir = "results"
}

workflow {
    // Main workflow logic here
}
```

### Reading a CSV file
```nextflow
channel
    .fromPath(params.input, checkIfExists: true)
    .splitCsv(header: true)
    .map { row ->
        def meta = [
            sample: row.sample,
            status: row.status
        ]
        [meta, file(row.fastq_1), file(row.fastq_2)]
    }
    .view()  // Print to stdout
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

### Required parameters
```bash
# Input samplesheet
--input "samplesheet.csv"

# Output directory
--outdir "results"

# 16S primers (V4 shown here)
--FW_primer "GTGYCAGCMGCCGCGGTAA"
--RV_primer "GGACTACNVGGGTWTCTAAT"
```

### Taxonomy databases
```bash
# SILVA (default, recommended)
--dada_ref_taxonomy "silva=138"

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
--skip_diversity true      # Skip alpha/beta diversity
--skip_barplot true        # Skip barplots
--skip_asv_plots true      # Skip ASV abundance plots
```

---

## Samplesheet Format

### CSV columns required:
```
sample,condition,status,fastq_1,fastq_2
```

### Example:
```csv
sample,condition,status,fastq_1,fastq_2
healthy_1,healthy,0,data/fastq/healthy1_R1.fastq.gz,data/fastq/healthy1_R2.fastq.gz
healthy_2,healthy,0,data/fastq/healthy2_R1.fastq.gz,data/fastq/healthy2_R2.fastq.gz
crc_patient_1,disease,1,data/fastq/crc1_R1.fastq.gz,data/fastq/crc1_R2.fastq.gz
crc_patient_2,disease,1,data/fastq/crc2_R1.fastq.gz,data/fastq/crc2_R2.fastq.gz
```

### Column definitions:
- **sample**: Unique sample identifier
- **condition**: Group label (e.g., "healthy", "disease")
- **status**: Binary status (0 = healthy/control, 1 = disease/case)
- **fastq_1**: Path to forward reads (R1)
- **fastq_2**: Path to reverse reads (R2)

---

## Output Directory Structure

```
results/
├── multiqc/                          # QC aggregation
│   └── multiqc_report.html           # Main QC dashboard
│
├── quality_control/
│   ├── fastqc/                       # Per-sample FASTQC reports
│   ├── cutadapt/                     # Primer trimming logs
│   └── dada2/                        # DADA2 denoising stats
│
├── abundance_tables/
│   ├── feature_table.tsv             # ASV × sample counts
│   ├── taxonomy.tsv                  # Taxonomic assignments
│   └── dada2_stats.tsv               # Read retention per sample
│
├── diversity_analysis/
│   ├── alpha_diversity.tsv           # Shannon, Chao1, etc.
│   ├── beta_diversity/
│   │   ├── bray_curtis_distance.tsv  # Pairwise distances
│   │   └── pcoa_plot.html            # Interactive PCoA plot
│   └── rarefaction_curves.html       # Rarefaction analysis
│
├── taxonomic_profiles/
│   ├── stacked_barplots/             # Taxa abundance by level
│   ├── heatmaps/                     # Relative abundance heatmaps
│   └── composition_plots/            # Phylum/genus-level plots
│
├── phyloseq_objects/
│   └── phyloseq.Rdata                # R phyloseq object
│
└── pipeline_info/
    ├── timeline.html
    ├── report.html
    └── trace.txt
```

---

## Key Output Files

### feature_table.tsv (ASV abundance)
```
ASV_ID      healthy_1  healthy_2  crc_patient_1  crc_patient_2
ASV_001     2500       2100       1800           1200
ASV_002     1200       1400       980            750
ASV_003     450        520        1900           2100
```

### taxonomy.tsv
```
ASV_ID     Taxonomy
ASV_001    d__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Faecalibacterium;g__Faecalibacterium;s__prausnitzii
ASV_002    d__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__vulgatus
```

### alpha_diversity.tsv
```
Sample         Observed_OTUs  Shannon  Chao1
healthy_1      250            5.2      275
healthy_2      245            5.1      268
crc_patient_1  180            4.1      195
crc_patient_2  175            4.0      190
```

---

## Common Commands

### Run full pipeline
```bash
bash main.sh
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
# Browse QC report
open results/multiqc/multiqc_report.html

# View feature table
head -20 results/abundance_tables/feature_table.tsv

# Check diversity metrics
cat results/diversity_analysis/alpha_diversity.tsv
```

---

## Troubleshooting

### Pipeline fails with "Docker daemon not running"
→ Start Docker Desktop

### Nextflow not found
→ Install: `curl -fsSL https://get.nextflow.io | bash`

### Out of memory
→ Upgrade Codespace to 4-core/16GB
→ Or reduce --max_cpus in nextflow.config

### Samplesheet validation fails
→ Check CSV format (comma-separated, no spaces)
→ Verify file paths exist
→ Ensure column names match exactly

---

## Further Reading

- **nf-core/ampliseq**: https://nf-co.re/ampliseq
- **DADA2 paper**: https://doi.org/10.1038/nmeth.3869
- **Nextflow docs**: https://www.nextflow.io/docs/latest/
- **QIIME2 diversity**: https://docs.qiime2.org/
