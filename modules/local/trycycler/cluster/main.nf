process TRYCYCLER_CLUSTER {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/trycycler"

    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(fastq)

    output:
    tuple val(meta), path("cluster/cluster_*") , emit: cluster_dir
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    cluster_dir = task.ext.prefix ?: "cluster"

    """
    trycycler \\
        cluster \\
        $args \\
        --assemblies $reads \\
        --reads ${fastq} \\
        --out_dir ${cluster_dir}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trycycler: \$(trycycler --version | sed 's/Trycycler v//')
    END_VERSIONS
    """
}
