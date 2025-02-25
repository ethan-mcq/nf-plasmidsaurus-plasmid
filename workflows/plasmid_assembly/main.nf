include { CAT_FASTQ } from '../../modules/nf-core/cat/fastq/main'
include { SEQKIT_SUBSEQ } from '../../modules/local/seqkit/subseq/main'
include { RASUSA } from '../../modules/nf-core/rasusa/main'
include { TRYCYCLER_SUBSAMPLE } from '../../modules/local/trycycler/subsample/main'
include { FLYE } from '../../modules/local/flye/main'
include { MEDAKA } from '../../modules/local/medaka/main'
include { PLANNOTATE_BATCH } from '../../modules/local/plannotate/batch/main'
include { MINIMAP2_ALIGN } from '../../modules/nf-core/minimap2/align/main.nf'
include { PLOT_HISTOGRAM } from '../../modules/local/toolbox/plot_histogram/main.nf'
include { PLOT_COVERAGE } from '../../modules/local/toolbox/plot_coverage/main.nf'

//other stuff here
include { ZIP } from '../../modules/nf-core/zip/main'

// Import subworkflows
include { ECOLI_FILTER } from '../../subworkflows/ecoli_filter'
include { TRYCYCLER_COMPLETE } from '../../subworkflows/trycycler_complete'


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
    
    // Read length and coverage histograms
    // Align reads to assembly
    MINIMAP2_ALIGN(ECOLI_FILTER.out.filtered_reads, MEDAKA.out.assembly, true, 'bai', false, false)

    PLOT_HISTOGRAM(ECOLI_FILTER.out.ecoli_reads, MINIMAP2_ALIGN.out.bam)

    PLOT_COVERAGE(MINIMAP2_ALIGN.out.bam, MEDAKA.out.assembly)

    // Collect all outputs you want to include in the TAR
    // Collect specific outputs for TAR
    cat_fastq_path = CAT_FASTQ.out.reads
        .map { meta, file -> file }
        .collect()

    plot_histogram_path = PLOT_HISTOGRAM.out.histogram
        .map { meta, file -> file }
        .collect()

    plot_coverage_path = PLOT_COVERAGE.out.histogram
        .map { meta, file -> file }
        .collect()

    medaka_assembly_path = MEDAKA.out.assembly
        .map { meta, file -> file }
        .collect()

    plannotate_html_path = PLANNOTATE_BATCH.out.html
        .map { meta, file -> file }
        .collect()

    plannotate_gbk_path = PLANNOTATE_BATCH.out.gbk
        .map { meta, file -> file }
        .collect()

    // Combine all collected paths
    all_paths = cat_fastq_path
        .mix(plot_histogram_path)
        .mix(plot_coverage_path)
        .mix(medaka_assembly_path)
        .mix(plannotate_html_path)
        .mix(plannotate_gbk_path)
        .collect()

    // Run ZIP module
    ZIP(all_paths, params.sample_id)

    emit:
    archive = ZIP.out.archive
}