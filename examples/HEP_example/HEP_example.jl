using LAMA
using BAT
using DensityInterface
using Dates
using Distributions
using Plots
using FHist
using ValueShapes
using IntervalSets

include("HEP_example_internals.jl")
#------------------------------------------------------------------------------
cd("C:\\Users\\Cornelius\\.julia\\dev\\LAMA\\examples")

#create a new LAMA.Storage object
st = Storage()
import LAMA.default_storage
LAMA.default_storage() = st

# create folder for analysis results
@store datetime = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS") # we recommended to always store datetime
result_path = "results/"*datetime*"/" 
mkpath(result_path)

# specify analysis details
@store channel = :electron 
@store mX = 90.05


# "load" data
# TODO: add "channel" -> change quality of samples
@store n_bins = 20
data = load_data(channel, mX)
data_hist = Hist1D(data, nbins=n_bins);

# plot data histogram
p = plot(data_hist, st=:scatter)
storefig(st, p, "plot data", result_path*"plot_data.png")


# fit: Normal vs Cauchy
@store fit_type = :Normal

fit_function, prior = if fit_type == :Normal
    _fit_function(params, x) = pdf(Normal(params.μ, params.σ), x)

    _prior = NamedTupleDist(
        μ = 50..150,
        σ = 0..60.,
    )
    _fit_function, _prior

elseif fit_type == :Cauchy
    _fit_function(params, x) = pdf(Cauchy(params.μ, params.σ), x)

    _prior = NamedTupleDist(
        μ = 50..150,
        σ = 0..60.,
    )
    _fit_function, _prior
end
#better practice: fit_function, prior = get_fitfunction_prior(fit_type)


likelihood = histogram_fit_likelihood(fit_function, data_hist) 
posterior = PosteriorMeasure(likelihood, prior)

@store sampling_algorithm = MCMCSampling(mcalg = MetropolisHastings(), nsteps = 10^5, nchains = 4, strict=false)
samples = bat_sample(posterior, sampling_algorithm).result

# plot samples 
p_μ = plot(samples, :μ, dpi=400)
storefig(st, p_μ, "plot μ", result_path*"plot_μ.png")

p_σ = plot(samples, :σ, dpi=400)
storefig(st, p_σ, "plot σ", result_path*"plot_σ.png")

@store best_fit_params = mode(samples)

# plot fit result
plot(-100.:1.:300., fit_function, samples, fillalpha=0.5, global_mode=false)

plot!(
    normalize(data_hist.hist), 
    color=:black, linewidth=2, 
    st = :scatter, fill=false, label = "Data",
    title = "Data & Best Fit",
)

storefig(st, p_σ, "plot σ", result_path*"plot_σ.png")


# save LAMAS.storage to file
write(st, result_path*"config2.toml") # .toml is recommended for readability
# write(st, result_path*"config.csv") 


