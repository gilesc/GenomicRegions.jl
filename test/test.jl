using GenomicRegion
using Iterators

function test_tabix_query()
    tbi = tabix("/home/gilesc/Data/transcripts/hg19/eg.bed.gz")
    for line in query(tbi, "chr1", 1:500000)
        println(line)
    end  
end

function test_read_bed()
    path = "/home/gilesc/Data/transcripts/hg19/eg.bed.gz"
    assert (length (grload (path)) == 23459)
end

function test_read_bedgraph()
    path = "/home/gilesc/Data/RNAseq/bg/DRR001622.bg.gz"
    h = gropen (path) 
    for item in take(h, 10) 
        println (item)
    end
end

#function write_regions_by_name(outdir :: String, regions)
#    mkdir_p(outdir)
#    for region in regions
#        file = replace(region.name, [' ', '/'], '_')".bed"
#        file = uppercase(file[1:1])file[2:end]
#        path = joinpath(outdir, file)
#        open(path, "a+") do io
#            write(io, convert(String, region)"\n")
#        end
#    end
#end  
