process EXON_TERMINUS_MINE {

    tag "$meta.id"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'docker.io/mdiblbiocore/rseqc_post:latest' }"

    input:
    tuple val(meta), path(junctions)
    val termini_len

    output:
    tuple val(meta), path("*.exon_termini.bed"), emit: termini

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    exon_terminus_mine.py \\
        $junctions \\
        $termini_len \\
        $args > ${prefix}.exon_termini.bed
    """
}

