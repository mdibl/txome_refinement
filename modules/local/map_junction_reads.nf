process MAP_JUNCTION_READS {

    tag "$meta1.id"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'mdiblbiocore/rseqc_post:latest' }"

    input:
    tuple val(meta1), path(rseqc_xls)
    tuple val(meta2), path(bed)

    output:
    tuple val(meta1), path("*.annotated_junction_coverage.bed"), emit: junctions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta1.id}"
    """
    map_junction_reads.py \\
        $bed \\
        $rseqc_xls \\
        $args \\
        > ${prefix}.annotated_junction_coverage.bed
    """
}

