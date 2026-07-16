#!/usr/bin/env nextflow
/*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LESSON 3: ASV Inference with DADA2 (3–4 min)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Concepts covered:
    - What are Amplicon Sequence Variants (ASVs)?
    - How does DADA2 work (error modeling, sequence inference)?
    - Why not OTUs (Operational Taxonomic Units)?
    - Output: feature × sample table

    Run:
        nextflow run course/03_asv_inference.nf

    Expected output: DADA2 workflow explanation (~5 seconds)
*/

nextflow.enable.dsl = 2

workflow {
    println("""
        ╔═════════════════════════════════════════════════════════════╗
        ║  LESSON 3: ASV Inference with DADA2 (3–4 min)              ║
        ║                                                              ║
        ║  What is an ASV?                                           ║
        ║  → Amplicon Sequence Variant: exact DNA sequence in sample ║
        ║  → Resolution: single nucleotide (not 97% clusters/OTUs)  ║
        ║  → Modern standard for 16S/18S/ITS analysis               ║
        ╚═════════════════════════════════════════════════════════════╝
    """)

    println("""
        ASVs vs. OTUs: Why the shift?
        ────────────────────────────
        
        OLD: OTU clustering (≥97% identity)
        • Sequences grouped artificially
        • Lose single-nucleotide variation
        • Different pipelines = different OTU calls (irreproducible)
        • Example: Two organisms differ by 1 nucleotide → same OTU
        
        NEW: ASV calling (exact sequence)
        • Preserve every nucleotide difference
        • Reproducible across runs / labs / studies
        • Can detect strain-level variation
        • Example: Two organisms differ by 1 nucleotide → two ASVs
    """)

    println("""
        DADA2 Error Modeling (Callahan et al., 2016)
        ────────────────────────────────────────────
        
        The DADA2 algorithm:
        
        1. SEQUENCE LEARNING PHASE
           Input: all forward reads from all samples
           • Learn error model: P(observed = A | true = G) for each Q-score
           • Identify rare sequences likely due to sequencing errors
        
        2. INFERENCE PHASE
           • Correct sequences based on error model
           • Cluster sequences that are 1 edit distance apart (likely errors)
           • Call Amplicon Sequence Variants (true biological sequences)
        
        3. MERGING PHASE
           • Merge corrected forward & reverse reads
           • Produce final ASV × sample abundance table
        
        OUTPUT:
           • ASV table: rows = ASVs, columns = samples, values = counts
           • ASV sequences: FASTA file of unique ASVs
           • Stats: read counts retained after each filter step
    """)

    println("""
        Expected DADA2 Output for Our 4 Samples
        ──────────────────────────────────────
        
        Input reads per sample:     ~5,000–10,000
        After primer trim:          ~4,500–9,000 (10% loss acceptable)
        After DADA2:                ~100–500 unique ASVs
        
        Feature table (ASV × sample):
        ┌─────────┬──────────┬──────────┬──────────┬──────────┐
        │ ASV_ID  │ healthy_1│ healthy_2│crc_pat_1 │crc_pat_2 │
        ├─────────┼──────────┼──────────┼──────────┼──────────┤
        │ ASV_001 │   2500   │   2100   │   1800   │   1200   │
        │ ASV_002 │   1200   │   1400   │    980   │    750   │
        │ ASV_003 │    450   │    520   │   1900   │   2100   │
        │  ...    │   ...    │   ...    │   ...    │   ...    │
        └─────────┴──────────┴──────────┴──────────┴──────────┘
    """)
}
