include { MINIMAP2_ALIGN } from '../modules/nf-core/minimap2/align/main'
include { SAMTOOLS_VIEW_KEEP_UNALIGNED } from '../modules/local/samtools/view_keep_unaligned/main'

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

    emit:
    filtered_reads = SAMTOOLS_VIEW_KEEP_UNALIGNED.out.bam
}
