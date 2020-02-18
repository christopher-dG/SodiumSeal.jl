using Base64: base64encode
using SodiumSeal: KeyPair, seal, unseal
using Test

const K = KeyPair()
const M = rand(UInt8, 100)

@testset "SodiumSeal.jl" begin
    @testset "Bytes" begin
        ciphertext = seal(M, K)
        decrypted = unseal(ciphertext, K)
        @test decrypted == M
    end

    @testset "Strings" begin
        ciphertext = seal(base64encode(M), K)
        decrypted = unseal(ciphertext, K)
        @test decrypted == base64encode(M)
    end
end
