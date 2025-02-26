include { CAT_FASTQ } from '../../modules/nf-core/cat/fastq/main'
include { MINIMAP2_ALIGN } from '../../modules/nf-core/minimap2/align/main'
include { RASUSA } from '../../modules/nf-core/rasusa/main'
include { TRYCYCLER_SUBSAMPLE } from '../../modules/nf-core/trycycler/subsample/main'
include { FLYE } from '../../modules/nf-core/flye/main'
include { MEDAKA } from '../../modules/nf-core/medaka/main'
//plannotate
include { LAST_DOTPLOT } from '../../modules/nf-core/last/dotplot/main'
//other stuff here

workflow PLASMID_ASSEMBLY_WORKFLOW {
    take:
    plasmid_input

    main:
    // cat fastq
    // filter out ecoli sequences with minimap2
    // subsample with rasusa
    // trycycler subsample
    // flye assembly
    // trycycler and medaka polish
    // plannotate
    // last dotplot
    // read length histogram
    // per base reference data tsv (samtools depth to reference?)
    // coverage plot
    // e coli contamination

    plasmid_input
        .flatten()
        .collate(4)
        .map { sample_id, bam_dir, barcode, req_number -> 
            println "Processing sample: $sample_id, barcode: $barcode, directory: $bam_dir"
            return [sample_id, bam_dir, barcode, req_number]
        }
        .set { samples }

    //emit:
    //ALL FILES THAT ARE GOING TO BE TARED
}
