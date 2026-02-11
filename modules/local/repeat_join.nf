process REPEAT_JOIN {

    tag "$meta.id"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'docker.io/mdiblbiocore/rseqc_post:latest' }"

    input:
    tuple val(meta), path(repeat_bed)
    tuple val(meta1), path(junctions)

    output:
    tuple val(meta), path("*.repeat_mask.counts.bed"), emit: junctions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    repeat_join.py \\
        $repeat_bed \\
        $junctions \\
        $args > ${prefix}.repeat_mask.counts.bed
    """
}

