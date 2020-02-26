using Base64: base64encode
using SodiumSeal: KeyPair, seal, unseal

k = KeyPair()
KeyPair(k.public)
KeyPair(base64encode(k.public))
KeyPair(k.public, k.secret)
KeyPair(base64encode(k.public), base64encode(k.secret))

s = "hello"
unseal(seal(Vector{UInt8}(s), k), k)
unseal(seal(base64encode(s), k), k)
