using GenomicRegion

h = gropen("/home/gilesc/Data/transcripts/hg19/eg.bed.gz")
rs = collect (h)

#for item in h
#    println (item)
#end

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
