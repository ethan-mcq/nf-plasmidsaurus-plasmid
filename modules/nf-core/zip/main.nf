process ZIP {
    tag "$sample_id"
    
    container 'ethanmcq/zip'  // Use a basic Ubuntu image that has zip installed

    input:
    path('files_to_zip/*')
    val sample_id

    output:
    tuple val(sample_id), path("${sample_id}.zip"), emit: archive
    path "versions.yml", emit: versions

    script:
    """
    zip -j ${sample_id}.zip files_to_zip/*
    
    cat <<-END_VERSIONS > versions.yml
    "PLASMID_ASSEMBLY_WORKFLOW:ZIP":
        zip: \$(zip -v | head -n 1 | sed 's/This is Zip //; s/(.*//')
    END_VERSIONS
    """
}