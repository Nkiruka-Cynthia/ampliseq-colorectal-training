#!/usr/bin/env nextflow
/*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LESSON 1: Understanding the 16S Samplesheet (2–3 min)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Quick lesson teaching:
    - CSV samplesheet format for ampliseq
    - How Nextflow parses metadata
    - Channel operations on tabular data

    Run:
        nextflow run course/01_samplesheet.nf

    Expected output: 4 samples printed instantly (~3 seconds)
*/

nextflow.enable.dsl = 2

params.input = "${projectDir}/data/samplesheet.csv"

workflow {
    println("""
        ╔═════════════════════════════════════════════════════════════╗
        ║  LESSON 1: 16S Samplesheet Structure (2–3 min)             ║
        ║                                                              ║
        ║  How does Nextflow read multi-sample 16S data?             ║
        ║  → Answer: From a simple CSV file!                         ║
        ╚═════════════════════════════════════════════════════════════╝
    """)

    println("\n Reading samplesheet: ${params.input}\n")

    // Load and parse the CSV
    ch_samples = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def meta = [
                sample    : row.sample,
                condition : row.condition,
                status    : row.status ?: '0'
            ]
            [
                meta,
                file(row.fastq_1, checkIfExists: false),
                file(row.fastq_2, checkIfExists: false)
            ]
        }

    // Display samples
    ch_samples.view { meta, r1, r2 ->
        "✓ [${meta.sample} | condition=${meta.condition} | status=${meta.status} | ${r1.name}]"
    }

    // Summary
    ch_samples
        .collect()
        .view { samples ->
            "\n Total samples: ${samples.size()}\n"
        }

    println("""
         Key columns in samplesheet.csv (in order):
        • sample:    Unique sample identifier
        • condition: Health status (healthy/disease)
        • status:    0=healthy/control, 1=disease/case
        • fastq_1:   Forward reads (R1, usually 16S F primer)
        • fastq_2:   Reverse reads (R2, usually 16S R primer)

        💡 status=1 flags disease samples so we can compare
           microbiome composition: healthy vs. colorectal cancer!
    """)
}
