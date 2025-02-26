process SAMTOOLS_VIEW_KEEP_UNALIGNED {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/samtools"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path(output), emit: bam, optional: true
    path  "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    output = task.ext.prefix ?: "${meta.id}.filtered.bam"
    """
    samtools \\
        view \\
        -b \\
        --threads ${task.cpus-1} \\
        -f 4 \\
        $args \\
        $input \\
        > $output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}