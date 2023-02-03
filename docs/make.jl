# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.

using Documenter
using Llama

makedocs(
    sitename = "Llama",
    modules = [Llama],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://github.com/Cornelius-G/Llama.jl/stable/"
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    linkcheck = !("nonstrict" in ARGS),
    strict = !("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/cornelius-g/Llama.jl.git",
    forcepush = true,
    push_preview = true,
)
