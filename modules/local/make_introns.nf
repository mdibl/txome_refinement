process MAKE_INTRONS {

    tag "$meta.id"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'docker.io/mdiblbiocore/rseqc_post:latest' }"

    input:
    tuple val(meta), path(gtf)

    output:
    tuple val(meta), path("*.sorted.introns.bed"), emit: introns

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    make_introns.py \\
        $gtf \\
        $prefix \\
        $args

    sort -n -k3,3 -k4,4 ${prefix}.introns.bed > ${prefix}.sorted.introns.bed
    """
}

