process SEQKIT_SUBSEQ {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/subseq"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.{fasta,fastq,fa,fq,fas,fna,faa}"), emit: fastx
    path "versions.yml",                                        emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args         ?: ""
    def prefix      = task.ext.prefix       ?: "${meta.id}"
    def file_type   = input instanceof List ? input[0].getExtension() : input.getExtension()
    """
    seqkit \\
        subseq \\
        -r 100:-100 \\
        $input \\
        $args \\
        > ${prefix}.${file_type}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqkit: \$(seqkit version | cut -d' ' -f2)
    END_VERSIONS
    """
}