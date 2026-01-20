process QC_TX {

    tag "$meta.id"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'docker.io/mdiblbiocore/qc_tx:latest' }"

    shell = ['/bin/sh', '-euo', 'pipefail']


    input:
    tuple val(meta), path(new_gtf)
    tuple val(meta1), path(gffcompare_gtf)
    tuple val(meta2), path(rsem_output)
    val(sample_fraction_threshold)
    val(count_threshold)
    val(gene_fraction_threshold)

    output:
    tuple val(meta),path("${meta.id}_filtered.gtf"), emit: filtered_gtf
    tuple val(meta),path("${meta.id}_transcripts_to_remove.txt"), emit: transcripts_to_remove
    tuple val(meta),path("*.html"), emit: combined_genes

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    grep "combined" $new_gtf | cut -f 9| cut -d";" -f 1| sed 's/^[a-z].[^"]*//'| sed 's/"//g' > combined.genes.txt

    post_process.py \\
    ${rsem_output} \\
    ${prefix} \\
    ${sample_fraction_threshold} \\
    ${count_threshold} \\
    ${gene_fraction_threshold} \\
    $args

    paste -d\$'\t' <(cut -f 9 $gffcompare_gtf | cut -d ';' -f 1| cut -d ' ' -f 2| sed 's/"//g') $gffcompare_gtf > temp.tsv
    awk 'NR==FNR{exclude[\$1]; next} !(\$1 in exclude)' ${prefix}_transcripts_to_remove.txt temp.tsv > tmp.gtf
    cut -f 2- tmp.gtf > ${prefix}_filtered.gtf
    """
}
