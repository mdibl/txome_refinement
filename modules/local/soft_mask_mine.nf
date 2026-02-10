process SOFT_MASK_MINE {

    tag "$meta.id"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'mdiblbiocore/rseqc_post:latest' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.repeat_masked.bed"), emit: masked_bed

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    soft_mask_miner.py \\
        $fasta \\
        $prefix \\
        $args
    """
}

