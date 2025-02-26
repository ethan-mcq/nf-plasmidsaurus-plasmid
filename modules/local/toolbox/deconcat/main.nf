process DECONCATENATE {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/deconcat"

    input:
    tuple val(meta), path(assemblies)
    val(approx_size)

    output:
    tuple val(meta), path("*.deconcat.fasta"), emit: deconcat
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    for assembly in $assemblies; do
        assembly_name=\$(basename \$assembly .fasta)
        python3 /data/deconcat.py \\
            \$assembly \\
            -o \${assembly_name}.deconcat.fasta \\
            --approx_size $approx_size \\
            $args
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deconcatenate: \$(python3 /data/deconcat.py --version 2>&1 | sed 's/^.*version //; s/Using.*\$//')
    END_VERSIONS
    """
}