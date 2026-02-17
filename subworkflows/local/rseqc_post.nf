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

    bam.view()
    ch_bed.view()

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
        MAP_JUNCTION_READS.out.junctions,
        MAKE_INTRONS.out.introns.first()
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
        EXON_TERMINUS_MINE.out.termini,
        SOFT_MASK_MINE.out.masked_bed.first()
    )

    REPEAT_JOIN (
        REPEAT_COUNT.out.intersect,
        OUTER_JOIN_ANNOTATION.out.junctions
    )


    emit:
    annotated_junctions              = REPEAT_JOIN.out.junctions    // channel: [ val(meta), counts ]
    
}