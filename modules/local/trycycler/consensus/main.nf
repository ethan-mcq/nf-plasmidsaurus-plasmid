process TRYCYCLER_CONSENSUS {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/trycycler"

    input:
    tuple val(meta), path(cluster_dir)

    output:
    tuple val(meta), path("${cluster_dir}/7_final_consensus.fasta") , emit: consensus_fasta
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    trycycler \\
        consensus \\
        --cluster_dir $cluster_dir

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trycycler: \$(trycycler --version | sed 's/Trycycler v//')
    END_VERSIONS
    """
}
