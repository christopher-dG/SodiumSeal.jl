module SodiumSeal

@static if VERSION >= v"1.3"
    using libsodium_jll: libsodium
else
    let deps = joinpath(@__DIR__, "..", "deps", "deps.jl")
        isfile(deps) || error(
            "SodiumSeal is not installed properly. ",
            """Run Pkg.build("SodiumSeal"), restart Julia and try again.""",
        )
        include(deps)
    end
end

export seal

using Base64: base64encode, base64decode

const SEALBYTES = Ref{Csize_t}()

### Errors ###

struct SodiumError
    fun::Symbol
    code::Int
end

Base.showerror(io::IO, e::SodiumError) = print(io, "$(e.fun) returned error code $(e.code)")

macro check(allowed, ex)
    fun = ex.args[2].args[1]
    return quote
        code = $(esc(ex))
        code in $allowed || throw(SodiumError($fun, code))
        code
    end
end

### Encryption ###

seal(plaintext, public_key::AbstractString) =
    base64encode(seal(plaintext, base64decode(public_key)))
function seal(plaintext, public_key)
    len = length(plaintext)
    dest = Vector{Cuchar}(undef, SEALBYTES[] + len)

    @check 0 ccall(
        (:crypto_box_seal, libsodium),
        Cint,
        (Ptr{Cuchar}, Ptr{Cuchar}, Culonglong, Ptr{Cuchar}),
        pointer(dest), pointer(plaintext), len, pointer(public_key),
    )

    return dest
end

### Init ###

function __init__()
    code = @check (0, 1) ccall((:sodium_init, libsodium), Cint, ())
    code == 0 && (SEALBYTES[] = ccall((:crypto_box_sealbytes, libsodium), Csize_t, ()))
end

end
