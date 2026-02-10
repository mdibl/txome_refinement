process OUTER_JOIN_ANNOTATION {

    tag "$meta1.id"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'mdiblbiocore/rseqc_post:latest' }"

    input:
    tuple val(meta1), path(junctions)
    tuple val(meta2), path(introns)

    output:
    tuple val(meta1), path("*.outer_joined.bed"), emit: junctions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta1.id}"
    """
    outer_join_introns.sh \\
        $junctions \\
        $introns \\
        $prefix \\
        $args
    """
}

