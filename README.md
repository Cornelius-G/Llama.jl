# Llama.jl - Llama Logs All My Analyses


<img src="icons/llama_julia.png" width="240" align="left"/>


[Llama](https://github.com/Cornelius-G/Llama) is a tool that helps you keep track of your analyses and simulations. It consists of two components, a logger and and viewer. Llama.jl is the logger for Julia and allows to generate logfiles of your analyses that can later be explored with the [Llama-Viewer](https://github.com/Cornelius-G/Llama-Viewer).
Its primary purpose is to keep track of the parameters and hyperparameters you use in your data analysis or simulation scripts.

As a researcher, you have probably also been in situations where you were not completely sure which exact settings you used or which parameters were set to which value when you showed the results and plots of your analysis or simulation. Or maybe you have experienced that you lost track of whether you have already performed an analysis with exactly these settings or not. 
Especially if you run the same analysis script several times with different settings, using Llama.jl and the [Llama-Viewer](https://github.com/Cornelius-G/Llama-Viewer) can help you keep track of all your analyses and quickly find the results and plots you are looking for.

<br/>

## Installation
```Julia
using Pkg
Pkg.add("https://github.com/Cornelius-G/Llama.jl")
```

## Usage
### 1) Setup
```Julia
using LlAMA 
```

create a new `LlAMA.Storage` instance to hold all the stored key-value pairs:
```Julia
st = Storage()
```
### 2) Adding variables to the storage
#### a) using the `store` function
Use the `store(storage::Llama.Storage, variable::Any, name::String)` function to store a value by explicitly passing the storage object, the variable, and a name to the storage:
```Julia
my_first_variable = 1
store(st, my_first_variable, "my_first_variable")
store(st, my_first_variable, "also_my_first_variable") # save the same value with a different name
```
#### b) Using the `@store` macro
For more convenient usage with the `@store` macro, a default storage object needs to be defined:
```Julia
import LAMA.default_storage
LAMA.default_storage() = st
```

The `@store` macro allows to store variables with their name in the default storage:
```Julia
@store my_second_variable = 2+5
@store my_third_variable = "This is a String"
@store my_array = rand(5)
@store my_symbol = :abcd
@store my_nt = (a=1, b=2)
```

```Julia
show(st)

LAMAS.Storage with 8 top-level entries:
my_third_variable = "This is a String"
also_my_first_variable = 1
my_first_symbol = ":a"
my_second_variable = 7
my_first_variable = 1
my_array = [0.7351191342002329, 0.6709238183126125, 0.242324052727378, 0.636459920624151, 0.45880780951411015]
my_symbol = ":abcd"

[my_nt]
my_nt = "NamedTuple"
b = 2
a = 1
```

### 3) Saving the storage by writing to file
The storage can be written to a .toml file (recommended for readability) or to a .csv file 
```Julia
write(st, "my_config.toml")
write(st, "my_config.csv")
```

## Further features

### Custom datatypes
The `@store` macro and the `store` function also work on more complex or custom data types by performing a simple serialization in a human-readable format:
```Julia
using BAT
@store algorithm = MetropolisHastings()
```
```
[algorithm]
algorithm = "MetropolisHastings"
weighting = "RepetitionWeighting"

    [algorithm.proposal]
    proposal = "BAT.MvTDistProposal"
    df = 1.0

    [algorithm.tuning]
    "λ" = 0.5
    tuning = "AdaptiveMHTuning"
    r = 0.5
    "β" = 1.5

        [algorithm.tuning.c]
        left = 0.0001
        c = "IntervalSets.Interval"
        right = 100.0

        [algorithm.tuning."α"]
        left = 0.15
        right = 0.35
        "α" = "IntervalSets.Interval"
```

### Plots
For plotting, the `storefig` functions allows to save the plot to a file (using `Plots.savefig`) and simultaneously stores its file path in the `Llama.Storage` so that the [Llama-Viewer]() can display it:
```Julia
using Plots
p = plot(rand(100))
storefig(st, p, "my_first_plot", "results/my_plot.pdf")
```
```
LAMAS.Storage with 1 top-level entries:
my_first_plot = "results/my_plot.pdf"
```

### Local variables
Also local variables can be stored with the `@store` macro, of course without them being added to global scope:
```Julia
function my_function()
    @store my_local_variable = 99
    @store my_local_symbol = :hello
end

my_function()
show(st)
```





