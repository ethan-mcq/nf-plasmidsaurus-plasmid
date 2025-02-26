process PLOT_HISTOGRAM {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/plot_histogram"

    input:
    tuple val(meta), path(ecoli_bam)
    tuple val(meta2), path(assembly_bam)

    output:
    tuple val(meta), path("*.png"), emit: histogram
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python3 /data/histogram.py \\
        $ecoli_bam \\
        $assembly_bam \\
        $prefix \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        histogram: \$(python3 /data/histogram.py --version 2>&1 | sed 's/^.*version //; s/Using.*\$//')
    END_VERSIONS
    """
}