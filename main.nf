#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import subworkflows
include { PLASMID_ASSEMBLY_WORKFLOW } from './workflows/plasmid-assembly/main'

// Import modules
include { TAR } from './modules/nf-core/tar/main'

workflow {
    // Call workflow with input_dir parameter
    PLASMID_ASSEMBLY_WORKFLOW(params.input_dir)

    // Prepare input for TAR module
    tar_input = PLASMID_ASSEMBLY_WORKFLOW.out.collect()
    tar_meta = [id: params.sample_id]

    // Run TAR module
    TAR(
        [tar_meta, tar_input],
        'gz'  // gz compression of all files
    )

    // Move TAR output to the specified outdir
    TAR.out.archive
        .map { meta, archive -> archive }
        .collectFile(name: "${params.sample_id}.tar.gz", storeDir: params.outdir) // pushes to output_dir param
}
