#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import subworkflows
include { PLASMID_ASSEMBLY_WORKFLOW } from './workflows/plasmid-assembly/main'

// Import modules
include { TAR } from './modules/nf-core/tar/main'

workflow {
    //parse sample sheet
    //call workflow
    //tar output


}