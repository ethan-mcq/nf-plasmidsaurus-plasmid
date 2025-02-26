process PLOT_COVERAGE {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/plot_coverage"

    input:
    tuple val(meta), path(assembly_bam)
    tuple val(meta2), path(assembly)

    output:
    tuple val(meta), path("*.png"), emit: histogram
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}.read_coverage"
    """
    python3 /data/coverage.py \\
        $assembly_bam \\
        $assembly \\
        $prefix \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coverage: \$(python3 /data/coverage.py --version 2>&1 | sed 's/^.*version //; s/Using.*\$//')
    END_VERSIONS
    """
}