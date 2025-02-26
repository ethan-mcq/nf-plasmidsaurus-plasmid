include { CAT_FASTQ } from '../../modules/nf-core/cat/fastq/main'
include { SEQKIT_SUBSEQ } from '../../modules/local/seqkit/subseq/main'
include { RASUSA } from '../../modules/nf-core/rasusa/main'
include { TRYCYCLER_SUBSAMPLE } from '../../modules/local/trycycler/subsample/main'
include { FLYE } from '../../modules/local/flye/main'
include { MEDAKA } from '../../modules/local/medaka/main'
include { PLANNOTATE_BATCH } from '../../modules/local/plannotate/batch/main'
//other stuff here
include { TAR } from '../../modules/nf-core/tar/main'

// Import subworkflows
include { ECOLI_FILTER } from '../../subworkflows/ecoli_filter'
include { TRYCYCLER_COMPLETE } from '../../subworkflows/trycycler_complete'
include { RL_HISTOGRAM } from '../../subworkflows/rl_histogram'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow PLASMID_ASSEMBLY_WORKFLOW {
    take:
    input_dir

    main:
    // Create [[:],[]] formatted list that includes metadata and all fastq file paths for CAT_FASTQ
    fastq_files = Channel.fromPath(input_dir, type: 'dir')
        .map { fastq_input_dir -> 
            def sample_id = params.sample_id
            def files = file("${input_dir}/*.fastq*")
            if (files.isEmpty()) {
                error "No FASTQ files found in ${input_dir}"
            }
            return [["id": sample_id, "single_end": true], files.flatten()]
        }

    // Cat fastq files
    CAT_FASTQ(fastq_files)

    // Filter out ecoli sequences with minimap2
    ECOLI_FILTER(CAT_FASTQ.out.reads, params.ecoli_ref)

    // Trim read ends by 100
    SEQKIT_SUBSEQ(ECOLI_FILTER.out.filtered_reads)
    
    // Downsample with rasusa
    rasusa_input = SEQKIT_SUBSEQ.out.fastx.map { meta, reads ->
        [meta, reads, params.genome_size]
    }

    RASUSA(rasusa_input, params.downsample_target_depth)

    // Trycycler subsample
    TRYCYCLER_SUBSAMPLE(RASUSA.out.reads, params.genome_size)

    // Assemble subsamples with Flye
    // Prepare input for FLYE
    flye_input = TRYCYCLER_SUBSAMPLE.out.subreads
        .transpose()
        .map { meta, reads -> 
            def new_meta = meta + [id: "${meta.id}_${reads.baseName}"]
            [new_meta, reads]
        }

    FLYE(flye_input, params.read_quality)

    // After FLYE process
    flye_assemblies = FLYE.out.fasta
        .map { meta, fasta -> fasta }
        .collect()
        .map { fastas -> 
            def meta = [id: params.sample_id]
            [meta, fastas]
        }

    // Trycycler assembly completion 
    TRYCYCLER_COMPLETE(flye_assemblies, RASUSA.out.reads)

    // Medaka polish
    MEDAKA(TRYCYCLER_COMPLETE.out.fastq, TRYCYCLER_COMPLETE.out.assembly)

    // plAnnotate
    PLANNOTATE_BATCH(MEDAKA.out.assembly, false)
    
    // Read length histogram
    RL_HISTOGRAM(MEDAKA.out.assembly, ECOLI_FILTER.out.filtered_reads, ECOLI_FILTER.out.ecoli_reads)
    
    // per base reference data tsv (samtools depth to reference?)
    // coverage plot -> per base reference out with visualization script
    // e coli contamination -> subworkflow with samtools view and python script


    // Collect all outputs you want to include in the TAR
    // .collect() only filepath
    cat_fastq_path = CAT_FASTQ.out.reads
        .map { meta, file -> file }
        .collect()

    all_outputs = cat_fastq_path.collect()

    // Prepare input for TAR module
    tar_meta = Channel.of([id: params.sample_id])

    // Run TAR module
    TAR(
        tar_meta.combine(all_outputs),
        '.gz'  // gz compression of all files
    )

    emit:
    archive = TAR.out.archive
}