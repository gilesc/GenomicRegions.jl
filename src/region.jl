using GZip

import Base.convert, Base.show

export STRAND_FORWARD, STRAND_REVERSE, STRAND_UNDEFINED

###################
# Strand definition
###################

immutable type Strand end
const STRAND_FORWARD = Strand()
const STRAND_REVERSE = Strand()
const STRAND_UNDEFINED = Strand()

function Base.convert(::Type{Strand}, c :: Char)
    if c == '+'
        STRAND_FORWARD
    elseif c == '-'
        STRAND_REVERSE
    else
        STRAND_UNDEFINED
    end
end

function Base.convert(::Type{Char}, s :: Strand)
    if s == STRAND_FORWARD 
        '+'
    elseif s == STRAND_REVERSE 
        '-'
    else 
        '.'
    end
end

###########################################
# Generic API for individual Region objects
###########################################

abstract Region

function contig(gr :: Region)
    gr.contig
end

function range(gr :: Region)
    gr.range
end

function range_start (gr :: Region)
    range(gr)[1]
end

function range_end (gr :: Region)
    range(gr)[end]
end

function name(gr :: Region)
    gr.name
end

function score(gr :: Region)
    gr.score
end

function strand(gr :: Region)
    gr.strand
end

function isless(r1 :: Region, r2 :: Region)
    contig(r1) < contig(r2) \
        | (range_start(r1) < range_start(r2)) 
        | (range_end(r1) < range_end(r2))
end

####################
# Generic Region I/O
####################

type RegionStream{T <: Region}
    handle :: IO
end

function write{T}(rio :: RegionStream{T},  r :: Region)
    write(rio.handle, convert(T, r))
end

function advance{T}(it :: RegionStream{T}) 
    try 
        read(it.handle, T)
    catch EOFError
        nothing
    end
end

Base.start{T}(it :: RegionStream{T}) = advance(it)
Base.next{T}(it :: RegionStream{T}, nxt) = (nxt, advance (it))
Base.done (it :: RegionStream, nxt) = ( nxt == nothing ) || eof (it.handle)

#########################################
# Mapping file extensions to Region types
#########################################

EXTENSIONS = Dict{String, Type}() 

function register_file_extension!{T <: Region}(::Type{T}, ext :: String)
    EXTENSIONS[ext] = T
end

function infer_region_type_from_path(path :: String)
    for (ext,t) in EXTENSIONS
        if endswith(lowercase(path), ext)
            return t
        end
    end
    EXTENSIONS[".bed"]
end
 
#######################################
# Generic region I/O ( High-level API )
#######################################

export gropen, grload, grsave
 
function gropen(path :: String, mode :: String = "r")
    handle = endswith(path, ".gz") ? gzopen(path, mode) : open(path, mode)
    t = infer_region_type_from_path(path)
    RegionStream{t}(handle)
end

function grload(path :: String)
    collect(gropen(path))
end

function grsave(path :: String, regions)
    h = gropen(path, "w")
    for r in regions
        write(h.handle, r)
    end
    close(h.handle)
end
