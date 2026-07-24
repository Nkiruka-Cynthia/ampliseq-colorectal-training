#!/usr/bin/env nextflow
/*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LESSON 1: Understanding the 16S Samplesheet + Metadata (2–3 min)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Quick lesson teaching:
    - The CSV samplesheet format ampliseq actually requires (sampleID,
      forwardReads, reverseReads)
    - Why grouping info (condition/status) lives in a SEPARATE metadata
      file, not the samplesheet
    - How Nextflow parses and joins tabular data
    - Channel operations on tabular data

    Run:
        nextflow run course/01_samplesheet.nf

    Expected output: 4 samples printed instantly (~3 seconds)
*/

nextflow.enable.dsl = 2

params.input    = "${projectDir}/data/samplesheet.csv"
params.metadata = "${projectDir}/data/Metadata.tsv"

workflow {
    println("""
        ╔═════════════════════════════════════════════════════════════╗
        ║  LESSON 1: 16S Samplesheet + Metadata Structure (2–3 min)  ║
        ║                                                              ║
        ║  How does Nextflow read multi-sample 16S data?             ║
        ║  → Answer: From a simple CSV file, plus a metadata TSV!    ║
        ╚═════════════════════════════════════════════════════════════╝
    """)

    println("\n Reading samplesheet: ${params.input}\n")
    println(" Reading metadata:    ${params.metadata}\n")

    // Load the samplesheet — this is what ampliseq itself requires:
    // sampleID, forwardReads, reverseReads (comma-separated)
    ch_samples = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            [row.sampleID, file(row.forwardReads, checkIfExists: false), file(row.reverseReads, checkIfExists: false)]
        }

    // Load the metadata — separate file, tab-separated, QIIME2-style
    // (first column header must be "ID")
    ch_metadata = channel
        .fromPath(params.metadata, checkIfExists: true)
        .splitCsv(header: true, sep: '\t')
        .map { row ->
            [row.ID, row.condition, row.status]
        }

    // Join samplesheet + metadata on the sample ID
    ch_joined = ch_samples
        .join(ch_metadata)

    // Display samples
    ch_joined.view { sample_id, r1, r2, condition, status ->
        "✓ [${sample_id} | condition=${condition} | status=${status} | ${r1.name}]"
    }

    // Summary
    ch_joined
        .collect()
        .view { samples ->
            "\n Total samples: ${samples.size() / 5}\n"
        }

    println("""
         Key columns in data/samplesheet.csv (what ampliseq requires):
        • sampleID:     Unique sample identifier
        • forwardReads: Forward reads (R1, usually 16S F primer)
        • reverseReads: Reverse reads (R2, usually 16S R primer)

         Key columns in data/Metadata.tsv (separate file, for grouping):
        • ID:        Must match sampleID exactly (QIIME2 requirement)
        • condition: Health status (healthy/disease)
        • status:    0=healthy/control, 1=disease/case

           ampliseq keeps FASTQ locations and sample grouping in two
           separate files — the samplesheet tells it WHERE the reads
           are, the metadata tells it HOW to group/compare samples
           (e.g. healthy vs. colorectal cancer) for diversity analysis.
    """)
}