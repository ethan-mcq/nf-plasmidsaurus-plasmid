# nf-plasmidsaurus-plasmid
## Introduction
I appreciate Rishud Handa and his team at Plasmidsaurus for looking at my work. I live and breathe Nanopore sequencing and love bioinformatics. Please feel free to ask me any questions about this workflow, my experience, or otherwise through [Linkedin](https://www.linkedin.com/in/ethanmcquhae/) or [email](mailto:ethan.mcq01@gmail.com). Enjoy!

This pipeline employs [Nextflow](https://www.nextflow.io/) and is able to depoly on [Seqera](https://seqera.io/) to create a scalable, elastic, and reproducable production bioinformatics pipeline. 

Refer to the documentation below for all style guides, Git versioning, and included subworkflows. 

## Table of Contents
- [Overview of the Pipeline](#overview-of-the-pipeline)

## Overview of the Pipeline
The folder structure is intentional:

```
nf-plasmidsaurus-plasmid/
├── assets/
│   └── Directory for other project files
├── modules/
│   └── Directory for Nextflow DSL2 modules
├── workflows/
│   └── Directory for Nextflow DSL2 subworkflows 
├── main.nf - The main Nextflow script file
├── nextflow.config - The main configuration file
├── modules.json - allows nf-core to keep track of nf-core installed dependencies
└── README.md
```
### main.nf
The entire pipeline is [DSL2](https://seqera.io/blog/dsl2-is-here/) optimized:
```
nextflow.enable.dsl = 2
```

`main.nf` is made to handle an incoming execution request like this one:
```
nextflow run ~/Desktop/nf-plasmidsaurus-plasmid/main.nf --input_dir ~/Desktop/nf-plasmidsaurus-plasmid/test/ --batch_id 250103-H
```

### nextflow.config
When a pipeline script is launched, Nextflow looks for configuration files in multiple locations. Since each configuration file may contain conflicting settings, they are applied in the following order (from lowest to highest priority):

    1. Parameters defined in pipeline scripts (e.g. main.nf)

    2. The config file $HOME/.nextflow/config, or $NXF_HOME/.nextflow/config when NXF_HOME is set (see NXF prefixed variables).

    3. The config file nextflow.config in the project directory

    4. The config file nextflow.config in the launch directory

    5. Config file specified using the -c <config-file> option

    6. Parameters specified in a params file (-params-file option)

    7. Parameters specified on the command line (--something value)

The base `nextflow.config` file is for declaring global variables that will be used in all workflows, subworkflows, and modules. 

### bin/ conf/ assets/    
Please refer to directory descriptions and files located in those directories for what belongs there. 

The `deconcat.py` script was taken and edited by myself to be more streamlined from the `wf-clonal-variation` Epi2Me pipeline. 

### assets/
`assets/` stores any reference [Dockerfiles](https://docs.docker.com/reference/dockerfile/), test files, reference genomes, and other files necessary for workflow execution.

Additionally, all test data used to produce this pipeline was accessed from the [Nanopore London Calling 2024 datasets repository](https://labs.epi2me.io/lc2024-datasets/) and downloaded from `s3://ont-open-data/londoncalling2024/rbk-plasmid`

### modules/ 
Modules are reusable, standardized building blocks for Nextflow pipelines. They are designed to simplify workflow development by providing pre-built, community-maintained processes for common bioinformatics tasks.

I have also developed my own modules to port into pipelines that follow standard nf-core style and formatting.

Key Features of [nf-core Modules](https://nf-co.re/modules/)

    Reusability – Modules can be used across multiple nf-core pipelines.
    Standardization – They follow best practices and nf-core guidelines.
    Version Control – Managed via GitHub, ensuring updates and improvements.
    Container Support – Comes with predefined Docker, Singularity, and Conda environments.
    Customization – Parameters can be modified to fit different workflows.

### workflows/ 
`workflows/` hosts subworkflows, which are reusable, modular components that groups multiple processes (`modules/`) together within a pipeline. It helps in organizing complex workflows by encapsulating a sequence of steps into a single unit, making the pipeline more manageable, reusable, and scalable.

Key Characteristics of a Subworkflow:

    Encapsulation – Combines multiple processes into a single logical unit.
    Reusability – Can be used across multiple Nextflow pipelines.
    Modularity – Helps keep workflows clean and structured.
    Improved Maintainability – Changes to a subworkflow update all pipelines that use it.

**MAIN POINT:** Do not perform analysis within the main workflow scripts. If analysis or calling of outside packages is necessary and there is not already a pre-built module, make one. 

---