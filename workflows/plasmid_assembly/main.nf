include { CAT_FASTQ } from '../../modules/nf-core/cat/fastq/main'
include { MINIMAP2_ALIGN } from '../../modules/nf-core/minimap2/align/main'
include { RASUSA } from '../../modules/nf-core/rasusa/main'
include { TRYCYCLER_SUBSAMPLE } from '../../modules/nf-core/trycycler/subsample/main'
include { FLYE } from '../../modules/nf-core/flye/main'
include { MEDAKA } from '../../modules/nf-core/medaka/main'
include { TAR } from '../../modules/nf-core/tar/main'
//plannotate
include { LAST_DOTPLOT } from '../../modules/nf-core/last/dotplot/main'
//other stuff here


// Import subworkflows
include { ECOLI_FILTER } from '../../subworkflows/ecoli_filter'

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

    // cat fastq files
    CAT_FASTQ(fastq_files)

    // filter out ecoli sequences with minimap2
    ECOLI_FILTER(CAT_FASTQ.out.reads, params.ecoli_ref)

    // subsample with rasusa
    // trycycler subsample
    // flye assembly
    // trycycler and medaka polish
    // plannotate
    // last dotplot
    // read length histogram
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