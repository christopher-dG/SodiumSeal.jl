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


end
