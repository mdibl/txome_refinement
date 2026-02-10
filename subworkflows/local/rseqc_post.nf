//
// Gene/transcript quantification with RSEM
//

include { RSEQC_JUNCTIONANNOTATION } from '../../modules/nf-core/rseqc/junctionannotation/main'
include { GFFREAD                  } from '../../modules/local/gffread'
include { BEDTOOLS_INTERSECT as ADD_ANNOTATION } from '../../modules/local/bedtools_intersect'
include { BEDTOOLS_INTERSECT as REPEAT_COUNT   } from '../../modules/local/bedtools_intersect'
include { MAP_JUNCTION_READS       } from '../../modules/local/map_junction_reads'
include { MAKE_INTRONS             } from '../../modules/local/make_introns'
include { OUTER_JOIN_ANNOTATION    } from '../../modules/local/outer_join_annotation'
include { EXON_TERMINUS_MINE       } from '../../modules/local/exon_terminus_mine'
include { SOFT_MASK_MINE           } from '../../modules/local/soft_mask_mine'
include { REPEAT_JOIN              } from '../../modules/local/repeat_join'

workflow RSEQC_POST_PROCESS {
    take:
    bam // channel: [ val(meta), [ reads ] ]
    gtf // channel: [ val(meta), [ gtf ] ]
    fasta // channel: [ val(meta), [ fasta ] ]

    main:

    GFFREAD (
        gtf
    )
    ch_bed = GFFREAD.out.bed

    RSEQC_JUNCTIONANNOTATION (
        bam,
        ch_bed
    )

    MAP_JUNCTION_READS (
        ch_bed,
        RSEQC_JUNCTIONANNOTATION.out.xls
    )

    MAKE_INTRONS (
        gtf
    )

    ADD_ANNOTATION (
        MAKE_INTRONS.out.introns.first(),
        MAP_JUNCTION_READS.out.junctions
    )

    OUTER_JOIN_ANNOTATION (
        ADD_ANNOTATION.out.intersect,
        MAKE_INTRONS.out.introns.first()
    )

    EXON_TERMINUS_MINE (
        OUTER_JOIN_ANNOTATION.out.junctions,
        params.termini_length
    )

    SOFT_MASK_MINE (
        fasta
    )

    REPEAT_COUNT (
        SOFT_MASK_MINE.out.masked_bed.first(),
        EXON_TERMINUS_MINE.out.termini
    )

    REPEAT_JOIN (
        REPEAT_COUNT.out.intersect,
        OUTER_JOIN_ANNOTATION.out.junctions
    )


    ch_versions = ch_versions.mix(RSEM_MERGE_COUNTS.out.versions)

    emit:
    counts_gene              = RSEM_CALCULATEEXPRESSION.out.counts_gene       // channel: [ val(meta), counts ]
    counts_transcript        = RSEM_CALCULATEEXPRESSION.out.counts_transcript // channel: [ val(meta), counts ]
    stat                     = RSEM_CALCULATEEXPRESSION.out.stat              // channel: [ val(meta), stat ]
    logs                     = RSEM_CALCULATEEXPRESSION.out.logs              // channel: [ val(meta), logs ]
    bam_star                 = RSEM_CALCULATEEXPRESSION.out.bam_star          // channel: [ val(meta), bam ]
    bam_genome               = RSEM_CALCULATEEXPRESSION.out.bam_genome        // channel: [ val(meta), bam ]
    bam_transcript           = RSEM_CALCULATEEXPRESSION.out.bam_transcript    // channel: [ val(meta), bam ]

    bam                      = BAM_SORT_STATS_SAMTOOLS.out.bam                // channel: [ val(meta), [ bam ] ]
    bai                      = BAM_SORT_STATS_SAMTOOLS.out.bai                // channel: [ val(meta), [ bai ] ]
    csi                      = BAM_SORT_STATS_SAMTOOLS.out.csi                // channel: [ val(meta), [ csi ] ]
    stats                    = BAM_SORT_STATS_SAMTOOLS.out.stats              // channel: [ val(meta), [ stats ] ]
    flagstat                 = BAM_SORT_STATS_SAMTOOLS.out.flagstat           // channel: [ val(meta), [ flagstat ] ]
    idxstats                 = BAM_SORT_STATS_SAMTOOLS.out.idxstats           // channel: [ val(meta), [ idxstats ] ]

    merged_counts_gene       = RSEM_MERGE_COUNTS.out.counts_gene              //    path: *.gene_counts.tsv
    merged_tpm_gene          = RSEM_MERGE_COUNTS.out.tpm_gene                 //    path: *.gene_tpm.tsv
    merged_counts_transcript = RSEM_MERGE_COUNTS.out.counts_transcript        //    path: *.transcript_counts.tsv
    merged_tpm_transcript    = RSEM_MERGE_COUNTS.out.tpm_transcript           //    path: *.transcript_tpm.tsv

    versions                 = ch_versions                                    // channel: [ versions.yml ]
}
