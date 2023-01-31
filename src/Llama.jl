module Llama

using DataFrames
using CSV
using Dates
using NamedTupleTools
using TOML
using Glob
using MacroTools
using Requires

include("logging.jl")

const _PLOTS_MODULE = Ref{Union{Module,Nothing}}(nothing)
_plots_module() = _PLOTS_MODULE[]

function __init__()
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" _PLOTS_MODULE[] = Plots
end

end
