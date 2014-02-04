using GenomicRegion

tbi = tabix("/home/gilesc/Data/transcripts/hg19/eg.bed.gz")
for line in query(tbi, "chr1", 1:500000)
    println(line)
end 
