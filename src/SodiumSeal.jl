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

export
    KeyPair,
    seal,
    unseal

using Base64: base64encode, base64decode

const SEALBYTES = Ref{Csize_t}()
const PUBLICKEYBYTES = Ref{Csize_t}()
const SECRETKEYBYTES = Ref{Csize_t}()

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

### Key pairs ###

"""
    KeyPair([public[, secret]])

Construct a new `KeyPair` with existing keys, or generate a new one.
If the keys are `AbstractString`s, they are assumed to be Base64-encoded.
If you are only interested in encrypting, you need not supply the secret key.
"""
struct KeyPair
    public::Vector{Cuchar}
    secret::Vector{Cuchar}
end

KeyPair(public) = KeyPair(public, [])
KeyPair(public::AbstractString) = KeyPair(public, "")
KeyPair(public::AbstractString, secret::AbstractString) =
    KeyPair(base64decode(public), base64decode(secret))
function KeyPair()
    public = Vector{Cuchar}(undef, PUBLICKEYBYTES[])
    secret = Vector{Cuchar}(undef, SECRETKEYBYTES[])

    @check 0 ccall(
        (:crypto_box_keypair, libsodium),
        Cint,
        (Ptr{Cuchar}, Ptr{Cuchar}),
        pointer(public), pointer(secret),
    )

    return KeyPair(public, secret)
end

Base.show(io::IO, k::KeyPair) = print(io, "KeyPair(...)")

### Encryption ###

"""
    seal(plaintext, keypair::KeyPair) -> Union{String, Vector{UInt8}}

Encrypt some data.

If `plaintext` is an `AbstractString`, it is assumed to be Base64-encoded,
and the output is also a Base64-encoded `String`.
Otherwise, it is a `Vector{UInt8}`.
"""
seal(plaintext::AbstractString, keypair::KeyPair) =
    base64encode(seal(base64decode(plaintext), keypair))
function seal(plaintext, keypair::KeyPair)
    len = length(plaintext)
    dest = Vector{Cuchar}(undef, SEALBYTES[] + len)

    @check 0 ccall(
        (:crypto_box_seal, libsodium),
        Cint,
        (Ptr{Cuchar}, Ptr{Cuchar}, Culonglong, Ptr{Cuchar}),
        pointer(dest), pointer(plaintext), len, pointer(keypair.public),
    )

    return dest
end

### Decryption ###

"""
    unseal(ciphertext, keypair::KeyPair) -> Union{String, Vector{UInt8}}

Decrypt some data.

If `ciphertext` is an `AbstractString`, it is assumed to be Base64-encoded,
and the output is also a Base64-encoded `String`.
Otherwise, it is a `Vector{UInt8}`.
"""
unseal(ciphertext::AbstractString, keypair::KeyPair) =
    base64encode(unseal(base64decode(ciphertext), keypair))
function unseal(ciphertext, keypair)
    len = length(ciphertext)
    dest = Vector{Cuchar}(undef, len - SEALBYTES[])

    @check 0 ccall(
        (:crypto_box_seal_open, libsodium),
        Cint,
        (Ptr{Cuchar}, Ptr{Cuchar}, Culonglong, Ptr{Cuchar}, Ptr{Cuchar}),
        pointer(dest), pointer(ciphertext), len, pointer(keypair.public), pointer(keypair.secret),
    )

    return dest
end

### Init ###

function __init__()
    code = @check (0, 1) ccall((:sodium_init, libsodium), Cint, ())
    if code == 0
        SEALBYTES[] = ccall((:crypto_box_sealbytes, libsodium), Csize_t, ())
        PUBLICKEYBYTES[] = ccall((:crypto_box_publickeybytes, libsodium), Csize_t, ())
        SECRETKEYBYTES[] = ccall((:crypto_box_secretkeybytes, libsodium), Csize_t, ())
    end
end

end
