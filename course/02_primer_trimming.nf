#!/usr/bin/env nextflow
/*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LESSON 2: Primer Trimming with Cutadapt (3 min)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Concepts covered:
    - Why remove primers? (primers = technical artifact, not biology)
    - How Cutadapt finds and removes them
    - Understanding trimming statistics (% of reads with primers found)

    Run:
        nextflow run course/02_primer_trimming.nf

    Expected output: Explanation of primer removal and simple statistics (~5 seconds)
*/

nextflow.enable.dsl = 2

params.FW_primer = "GTGYCAGCMGCCGCGGTAA"  // 16S V4 forward primer
params.RV_primer = "GGACTACNVGGGTWTCTAAT" // 16S V4 reverse primer

workflow {
    println("""
        ╔═════════════════════════════════════════════════════════════╗
        ║  LESSON 2: Primer Trimming with Cutadapt (3 min)          ║
        ║                                                              ║
        ║  Why trim primers?                                         ║
        ║  → Primers are PCR artifacts, not biological sequences     ║
        ║  → They confound DADA2 error modeling                      ║
        ║  → Removing them improves ASV quality                      ║
        ╚═════════════════════════════════════════════════════════════╝
    """)

    println("\n 16S V4 Region Primers (Caporaso et al., 2011)\n")
    println(" Forward (F): ${params.FW_primer}")
    println(" Reverse (R): ${params.RV_primer}")
    println(" Expected product: ~250–290 bp\n")

    println("""
        How Cutadapt works:
        ────────────────────
        
        Input FASTQ (paired-end):
          Read R1: [F-primer]--[16S-V4-sequence]--[technical-tail]
          Read R2: [R-primer]--[16S-V4-sequence]--[technical-tail]
        
        Step 1: Find primers in forward & reverse reads
        Step 2: Trim primers (keep only 16S V4 sequence)
        Step 3: Remove reads where primers not found (low quality)
        
        Output FASTQ (trimmed):
          Read R1: [16S-V4-sequence]
          Read R2: [16S-V4-sequence]
        
        Performance metrics to watch:
        • % reads with F primer found (should be > 90%)
        • % reads with R primer found (should be > 90%)
        • Median insert length after trimming (~250 bp for V4)
    """)

    println("""
        In the full pipeline (main.sh):
        ────────────────────────────────
        
        Cutadapt will:
        1. Trim ${params.FW_primer.length()}-bp forward primer from R1
        2. Trim ${params.RV_primer.length()}-bp reverse primer from R2
        3. Report % of reads where primers were found
        4. Output MultiQC statistics
        5. Pass trimmed reads to DADA2
    """)
}