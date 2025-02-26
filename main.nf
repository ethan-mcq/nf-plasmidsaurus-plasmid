#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import subworkflows
include { PLASMID_ASSEMBLY_WORKFLOW } from './workflows/plasmid_assembly/main'

// Import modules
include { TAR } from './modules/nf-core/tar/main'

workflow {
    // Call workflow with input_dir parameter
    PLASMID_ASSEMBLY_WORKFLOW(params.input_dir)

    // Move TAR output to the specified outdir
    PLASMID_ASSEMBLY_WORKFLOW.out.archive
        .map { meta, archive -> archive }
        .collectFile(name: "${params.sample_id}.tar.gz", storeDir: params.output_dir ?: 'results')
}