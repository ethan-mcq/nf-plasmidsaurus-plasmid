process RASUSA {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/rasusa"

    input:
    tuple val(meta), path(reads), val(genome_size)
    val   depth_cutoff

    output:
    tuple val(meta), path('*.fastq.gz'), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output   = task.ext.prefix ?: "--output ${prefix}.fastq.gz"
    """
    rasusa \\
        reads \\
        $args \\
        --coverage $depth_cutoff \\
        --genome-size $genome_size \\
        $reads \\
        $output
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rasusa: \$(rasusa --version 2>&1 | sed -e "s/rasusa //g")
    END_VERSIONS
    """
}
