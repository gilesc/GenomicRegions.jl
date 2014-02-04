import Base.convert

export BED, RegionFile, write_regions_by_name

type BED
    chrom :: String
    start_base :: Int
    end_base :: Int
    name :: String
    score :: Float64
    strand :: Char 
end

function Base.convert(::Type{BED}, s :: String)
    fields = split(strip(s), '\t')
    name = if length(fields)>3 fields[4] else "." end
    score = if length(fields)>4 float(fields[5]) else NaN end
    strand = if length(fields)>5 fields[6][1] else '.' end
    BED(fields[1], int(fields[2]), int(fields[3]), name, score, strand)
end

function Base.convert(::Type{String}, bed :: BED)
    "$(bed.chrom)\t$(bed.start_base)\t$(bed.end_base)\t$(bed.name)\t$(bed.score)\t$(bed.strand)"
end

function read_bed(path :: String)
    # Lazily read a BED file. Note, the file handle is only closed
    # when all records are consumed.
    @task open(path) do io
        while !eof(io)
        end
    end
end


function write_regions_by_name(outdir :: String, regions)
    mkdir_p(outdir)
    for region in regions
        file = replace(region.name, [' ', '/'], '_')".bed"
        file = uppercase(file[1:1])file[2:end]
        path = joinpath(outdir, file)
        open(path, "a+") do io
            write(io, convert(String, region)"\n")
        end
    end
end

function RegionFile(path :: String)
    t = BED
    @task begin
        io = if endswith(path,".gz") gzopen(path) else open(path) end
        while !eof(io)
            convert(t, io |> readline |> strip) |> produce
        end
        close(io)
    end
end
