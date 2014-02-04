import Base.convert

export BEDGraph

type BEDGraph <: Region
    contig :: String
    range :: Range1{Int}
    score :: Float64
end

register_file_extension!(BEDGraph, ".bg")
register_file_extension!(BEDGraph, ".bg.gz")
register_file_extension!(BEDGraph, ".bedGraph")
register_file_extension!(BEDGraph, ".bedGraph.gz")

function Base.read(io :: IO, ::Type{BEDGraph})
    while !eof(io)
        try
            return convert(BEDGraph, readline(io))
        catch
            continue
        end
    end
    throw(EOFError())
end

function Base.convert(::Type{BEDGraph}, s :: String)
    fields = split(strip(s), '\t')
    BEDGraph(fields[1], int(fields[2]):int(fields[3]), float(fields[4]))
end

strand (r :: BEDGraph) = STRAND_UNDEFINED
name (r :: BEDGraph) = ""
