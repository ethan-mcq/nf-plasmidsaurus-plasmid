include { DECONCATENATE } from '../modules/local/toolbox/deconcat/main'
include { TRYCYCLER_CLUSTER } from '../modules/local/trycycler/cluster/main'
include { TRYCYCLER_RECONCILE } from '../modules/local/trycycler/reconcile/main'
include { TRYCYCLER_MSA } from '../modules/local/trycycler/msa/main'
include { TRYCYCLER_PARTITION } from '../modules/local/trycycler/partition/main'
include { TRYCYCLER_CONSENSUS } from '../modules/local/trycycler/consensus/main'

////////////////////////////////////////////////////
/* --           RUN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow TRYCYCLER_COMPLETE {
    take:
    assemblies // This should be a tuple of [meta, [fasta1, fasta2, fasta3]]
    reads      // This should be the original reads used for assembly

    main:
    DECONCATENATE(assemblies, params.genome_size)
    TRYCYCLER_CLUSTER(DECONCATENATE.out.deconcat, reads)
    TRYCYCLER_RECONCILE(reads, TRYCYCLER_CLUSTER.out.cluster_dir)
    TRYCYCLER_MSA(TRYCYCLER_RECONCILE.out.cluster_dir)
    TRYCYCLER_PARTITION(reads, TRYCYCLER_MSA.out.cluster_dir)
    TRYCYCLER_CONSENSUS(TRYCYCLER_PARTITION.out.cluster_dir)

    emit:
    fastq = TRYCYCLER_CONSENSUS.out.consensus_fastq
    assembly = TRYCYCLER_CONSENSUS.out.consensus_fasta
}
