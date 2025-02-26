process TRYCYCLER_RECONCILE {
    tag "$meta.id"
    label 'process_medium'
    errorStrategy 'retry'
    maxRetries 3

    conda "${moduleDir}/environment.yml"
    container "ethanmcq/trycycler"

    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(cluster_dir)

    output:
    tuple val(meta), path(cluster_dir) , emit: cluster_dir
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    #!/bin/bash
    set -e

    # Function to run Trycycler reconcile and handle errors
    run_trycycler_reconcile() {
        trycycler reconcile \\
            $args \\
            --reads ${reads} \\
            --cluster_dir $cluster_dir \\
            --max_trim_seq_percent 20 \\
            --max_add_seq_percent 10 \\
            --verbose \\
            2>&1 | tee trycycler_output.log

        if grep -q "Error: the following sequences failed to circularise:" trycycler_output.log; then
            problematic_contigs=\$(grep "Error: the following sequences failed to circularise:" -A1 trycycler_output.log | tail -n1 | tr -d ' ')
            echo "Removing problematic contigs: \$problematic_contigs"
            for contig in \$(echo \$problematic_contigs | tr ',' ' '); do
                rm -f \$cluster_dir/1_contigs/\${contig}.fasta
            done
            return 1
        fi
        return 0
    }

    # Run Trycycler reconcile and retry if needed
    max_attempts=3
    attempt=1
    while [ \$attempt -le \$max_attempts ]; do
        echo "Attempt \$attempt of \$max_attempts"
        if run_trycycler_reconcile; then
            echo "Trycycler reconcile completed successfully"
            break
        else
            echo "Trycycler reconcile failed, retrying..."
            attempt=\$((attempt + 1))
        fi
    done

    if [ \$attempt -gt \$max_attempts ]; then
        echo "Trycycler reconcile failed after \$max_attempts attempts"
        exit 1
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trycycler: \$(trycycler --version | sed 's/Trycycler v//')
    END_VERSIONS
    """
}