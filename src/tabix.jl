import Base.close, Base.start, Base.next, Base.done

export tabix, query

type Tabix
    ptr :: Ptr{Uint8}
    is_open :: Bool
end

function Base.close(tbi :: Tabix)
    if tbi.is_open
        ccall((:ti_close, "libtabix"), Void, (Ptr{Uint8},), tbi.ptr)
        tbi.is_open = false
    end
    tbi
end

function tabix(path :: String)
    ptr = ccall((:ti_open, "libtabix"), 
                Ptr{Uint8}, 
                (Ptr{Uint8}, Int),
                bytestring(path),
                0)
    tbi = Tabix(ptr, true)
    finalizer(tbi, Base.close)
    tbi
end

# Iterator stuff

type TabixIterator
    ptr :: Ptr{Uint8}
    owner :: Tabix
    contig :: String
    range :: Range1{Int}

    next_line :: String
    done :: Bool
end

function finalize(tbii :: TabixIterator)
    ccall((:ti_iter_destroy, "libtabix"),
          Void,
          (Ptr{Uint8},),
          tbii.ptr)
    tbii.done = true
end

function TabixIterator(tbi :: Tabix, contig :: String, range :: Range1{Int})
    ptr = ccall((:ti_query, "libtabix"),
                Ptr{Uint8},
                (Ptr{Uint8}, Ptr{Uint8}, Int, Int),
                tbi.ptr, bytestring(contig), range[1], range[end]) 
    if (ptr == C_NULL) # Zero search results
        tbii = TabixIterator(ptr, tbi, contig, range, "", true)
    else
        tbii = TabixIterator(ptr, tbi, contig, range, "", false)
        finalizer(tbii, finalize)
        advance!(tbii)
    end
    tbii
end

function advance!(tbii :: TabixIterator)
    line = ccall((:ti_read, "libtabix"),
                 Ptr{Uint8},
                 (Ptr{Uint8}, Ptr{Uint8}, Ptr{Uint8}),
                 tbii.owner.ptr, tbii.ptr, 0)
    if (line == C_NULL)
        tbii.done = true
    else
        tbii.next_line = bytestring(line)
    end
end
 
# FIXME: make a new TabixIterator
Base.start(tbii :: TabixIterator) = nothing
function Base.next(tbii :: TabixIterator, nil)
    data = tbii.next_line
    advance!(tbii)
    (data, nothing)
end
Base.done(tbii :: TabixIterator, nil) = tbii.done
 
function query(tbi :: Tabix, contig :: String, range :: Range1{Int})
    TabixIterator(tbi, contig, range)
end
