#!/usr/bin/env nextflow
/*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LESSON 4: Taxonomy Assignment (3 min)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Concepts covered:
    - How taxonomy assignment works (sequence similarity searches)
    - Reference databases: SILVA, RDP, Greengenes
    - Taxonomic ranks: Kingdom → Phylum → Class → Order → Family → Genus → Species
    - Output: feature × taxa matrix

    Run:
        nextflow run course/04_taxonomy_assignment.nf

    Expected output: Taxonomy workflow explanation (~5 seconds)
*/

nextflow.enable.dsl = 2

workflow {
    println("""
        ╔═════════════════════════════════════════════════════════════╗
        ║  LESSON 4: Taxonomy Assignment (3 min)                     ║
        ║                                                              ║
        ║  How do we know which bacterium is in our sample?          ║
        ║  → Compare each ASV to a reference database                ║
        ║  → Find best match → assign taxonomy                       ║
        ╚═════════════════════════════════════════════════════════════╝
    """)

    println("""
        Taxonomic Ranks (Linnaean Hierarchy)
        ───────────────────────────────────
        
        Kingdom:  Bacteria
         Phylum:   Bacteroidetes
         Class:    Bacteroidia
         Order:    Bacteroidales
         Family:   Bacteroidaceae
         Genus:    Bacteroides
         Species:  vulgatus
        
        Hierarchical taxonomy allows us to:
        • Identify organisms at any specificity level
        • Compare between samples (e.g., % Bacteroides in healthy vs CRC)
        • Group related taxa for analysis
    """)

    println("""
        Reference Databases for 16S Classification
        ───────────────────────────────────────────
        
        SILVA (https://www.arb-silva.de/)
        • Most comprehensive: 600,000+ sequences
        • Default in ampliseq
        • Regular updates (v138, v132, etc.)
        • Recommended for most studies
        
        RDP (Ribosomal Database Project)
        • Focus on validating taxonomy
        • 18,000+ sequences
        • Bootstrap confidence scores
        
        Greengenes (now deprecated)
        • Earlier standard (legacy studies)
        • Last update: 2013
    """)

    println("""
        Taxonomy Assignment Workflow
        ────────────────────────────
        
        INPUT:  ASVs (unique 16S sequences)
        
        STEP 1: Search
          • Use USEARCH or VSEARCH
          • Compare each ASV to SILVA reference
          • Find top hits (100% match or closest)
        
        STEP 2: Score
          • Calculate percent identity
          • Evaluate alignment quality
          • Typically: >97% similarity = good assignment
        
        STEP 3: Assign
          • Extract taxonomy string from best match
          • Add confidence score
          • Handle unclassified/ambiguous cases
        
        OUTPUT: Taxonomy table
          ASV_001    Bacteria;Bacteroidetes;Bacteroidia;Bacteroidales;...
          ASV_002    Bacteria;Firmicutes;Clostridia;Clostridiales;...
          ASV_003    Bacteria;Actinobacteria;Actinobacteria;...
    """)

    println("""
        Expected Output for CRC vs Healthy Microbiome
        ─────────────────────────────────────────────
        
        HEALTHY CONTROLS (enriched taxa):
        • Faecalibacterium prausnitzii (Firmicutes) — anti-inflammatory
        • Roseburia species (Firmicutes) — butyrate producer
        • Akkermansia muciniphila — mucus layer regulation
        
        CRC PATIENTS (enriched taxa):
        • Fusobacterium nucleatum — pro-inflammatory
        • Porphyromonas gingivalis (Bacteroides)
        • Reduced: Faecalibacterium, Roseburia
        
        Why this matters:
        → DADA2 + taxonomy = identify which specific bacteria
        → Compare: dysbiosis markers in disease vs healthy
        → Generate: diversity metrics (alpha/beta)
    """)
}
