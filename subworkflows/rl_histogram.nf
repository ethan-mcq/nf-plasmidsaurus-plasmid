include { MINIMAP2_ALIGN } from '../modules/nf-core/minimap2/align/main'
include { PLOT_HISTOGRAM } from '../modules/local/toolbox/plot_histogram/main'

////////////////////////////////////////////////////
/* --           RUN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow RL_HISTOGRAM {
    take:
    assembly
    fastq
    ecoli_bam

    main:

    MINIMAP2_ALIGN(fastq, assembly, true, 'bai', false, false)

    PLOT_HISTOGRAM(ecoli_bam, MINIMAP2_ALIGN.out.bam)

    emit:
    plot = PLOT_HISTOGRAM.out.histogram
}
