using SodiumSeal
using Documenter

makedocs(;
    modules=[SodiumSeal],
    authors="Chris de Graaf <chrisadegraaf@gmail.com>",
    repo="https://github.com/christopher-dG/SodiumSeal.jl/blob/{commit}{path}#L{line}",
    sitename="SodiumSeal.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://christopher-dG.github.io/SodiumSeal.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/christopher-dG/SodiumSeal.jl",
)
