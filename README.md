# GenomicRegion

A Julia package for handling sets of genomic regions, with in-memory and
on-disk indexing capabilities.

Current capabilities:

- Reads BED format
- Query tabix indexes
 
Planned capabilities:

- Read/write other genomic region formats: GFF/GTF/etc
- Intra-format conversion
- In-memory Interval Tree index
- On-disk BBI (BigWig/BigBED) format indexes
- Calculate statistics for intersection and proximity of sets of genomic regions
