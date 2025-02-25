process MEDAKA {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/medaka"

    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(assembly)

    output:
    tuple val(meta), path("*.fa"), emit: assembly
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    medaka_consensus \\
        -t $task.cpus \\
        $args \\
        -i $reads \\
        -d $assembly \\
        -o ./

    mv consensus.fasta ${prefix}.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        medaka: \$( medaka --version 2>&1 | sed 's/medaka //g' )
    END_VERSIONS
    """
}
