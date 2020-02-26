# SodiumSeal

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://christopher-dG.github.io/SodiumSeal.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://christopher-dG.github.io/SodiumSeal.jl/dev)
[![Build Status](https://travis-ci.com/christopher-dG/SodiumSeal.jl.svg?branch=master)](https://travis-ci.com/christopher-dG/SodiumSeal.jl)
[![Codecov](https://codecov.io/gh/christopher-dG/SodiumSeal.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/christopher-dG/SodiumSeal.jl)

SodiumSeal wraps [libsodium](https://download.libsodium.org/doc)'s [sealed boxes](https://download.libsodium.org/doc/public-key_cryptography/sealed_boxes).

```jl
julia> using SodiumSeal

julia> k = KeyPair()
KeyPair(...)

julia> plaintext = rand(UInt8, 4)
4-element Array{UInt8,1}:
 0x72
 0x01
 0xbd
 0x23

julia> ciphertext = seal(plaintext, k);

julia> unseal(ciphertext, k)
4-element Array{UInt8,1}:
 0x72
 0x01
 0xbd
 0x23
```

You can also work with existing keys and Base64-encoded data.

```julia
julia> using Base64, SodiumSeal

julia> k = KeyPair("IOI7mQ2HxD6yrtVlD/HdQ0YRJVdwKfdf9+VOeuvXjDI=")
KeyPair(...)

julia> plaintext = base64encode(rand(UInt8, 4))
"qrSWSQ=="

julia> seal(plaintext, k)
"Y82B4YedK8EfA7MoBVG1GUlfq28c+khmHT1gENk8m0dyBvJlyh+wCud8JkLTrGXyAShP2w=="
```
