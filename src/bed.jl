import Base.convert

export BED

type BED <: Region
    contig :: String
    range :: Range1{Int}
    name :: String
    score :: Float64
    strand :: Char 
end

register_file_extension!(BED, ".bed")
register_file_extension!(BED, ".bed.gz")

function read(io :: IO, ::Type{BED})
    while !eof(io)
        try
            return convert(BED, readline(io))
        catch
            continue
        end
    end
    throw(EOFError())
end

function Base.convert(::Type{BED}, s :: String)
    fields = split(strip(s), '\t')
    name = if length(fields)>3 fields[4] else "." end
    score = if length(fields)>4 float(fields[5]) else NaN end
    strand = if length(fields)>5 fields[6][1] else '.' end
    BED(fields[1], int(fields[2]):int(fields[3]), 
                   name, 
                   score, 
                   convert(Strand, strand))
end

function Base.convert(::Type{String}, bed :: BED)
    "$(bed.contig)\t$(bed.range[1])\t$(bed.range[end])\t$(bed.name)\t$(bed.score)\t$(bed.strand)\n"
end
