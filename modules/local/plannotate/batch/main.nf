process PLANNOTATE_BATCH {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::plannotate=1.2.0"
    container "ontresearch/plannotate"

    input:
    tuple val(meta), path(fasta)
    val(linear)

    output:
    tuple val(meta), path("*.gbk"), emit: gbk
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.csv"), optional: true, emit: csv
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def linear_arg = linear ? "--linear" : ""
    """
    plannotate batch \\
        -i $fasta \\
        -o . \\
        -f ${prefix} \\
        -h \\
        -c \\
        $linear_arg \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        plannotate: \$(plannotate --version 2>&1 | sed 's/^.*version //; s/Using.*\$//')
    END_VERSIONS
    """
}