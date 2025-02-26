include { MINIMAP2_ALIGN } from '../modules/nf-core/minimap2/align/main'
include { SAMTOOLS_VIEW_KEEP_UNALIGNED } from '../modules/local/samtools/view_keep_unaligned/main'
include { SAMTOOLS_VIEW_KEEP_ALIGNED } from '../modules/local/samtools/view_keep_aligned/main'
include { SAMTOOLS_BAM2FQ } from '../modules/local/samtools/bam2fq/main'
include { GUNZIP } from '../modules/nf-core/gunzip/main'

////////////////////////////////////////////////////
/* --           RUN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow ECOLI_FILTER {
    take:
    cat_fastq
    ecoli_ref

    main:
    // Align fastq to ecoli reference
    MINIMAP2_ALIGN(cat_fastq, [[:],[ecoli_ref]], true, 'bai', false, false)

    // Remove all aligned reads
    SAMTOOLS_VIEW_KEEP_UNALIGNED(MINIMAP2_ALIGN.out.bam)

    SAMTOOLS_VIEW_KEEP_ALIGNED(MINIMAP2_ALIGN.out.bam)

    SAMTOOLS_BAM2FQ(SAMTOOLS_VIEW_KEEP_UNALIGNED.out.bam, false)

    GUNZIP(SAMTOOLS_BAM2FQ.out.reads)
    
    emit:
    filtered_reads = GUNZIP.out.gunzip
    ecoli_reads = SAMTOOLS_VIEW_KEEP_ALIGNED.out.bam
}
