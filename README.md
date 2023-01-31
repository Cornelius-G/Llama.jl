# Llama.jl


<img src="icons/llama_julia.png" width="240" align="left"/>


**Hi, I'm Llama and I will help you log your analyses so you can keep track of all of them.**

Llama.jl is part of the [Llama project](https://github.com/Cornelius-G/Llama). It is a tool that helps you keep track of your analyses and simulations.
Llama.jl is the LLama logging package for Julia and allows to generate logfiles of your analyses which can late be explored with the Llama-Viewer.

<br/>

## Installation
```Julia
using Pkg
Pkg.add("https://github.com/Cornelius-G/Llama.jl")
```

## Usage
```Julia
using LlAMA 
```

create a new `LlAMA.Storage` instance to hold all the stored key-value pairs:
```Julia
st = Storage()
```

use the `store(storage::Llama.Storage, variable::Any, name::String)` function to store a variable by explicitly passing the storage object, the variable, and a name to the storage:
```Julia
my_first_variable = 1
store(st, my_first_variable, "my_first_variable")
store(st, my_first_variable, "also_my_first_variable") # save the same value with a different name
```

For more convenient usage with the `@store` macro, a default storage object needs to be defined:
```Julia
import LAMA.default_storage
LAMA.default_storage() = st
```

The `@store` macro then allows to store variables with their name in the default storage:
```Julia
@store my_second_variable = 2+5
@store my_third_variable = "This is a String"
@store my_array = rand(5)
@store my_symbol = :abcd
@store my_nt = (a=1, b=2)
```

show(st)

It can often be helpful to store the date and time of code execution:
```Julia
using Dates
@store datetime = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
```

The `@store` macro and the `store` function also work on complex/custom data types by performing a simple serialization in a human-readable format:
```Julia
using BAT
@store algorithm = MetropolisHastings()
```

show(st)

Also local variables can be stored with the `@store` macro, of course without them being added to global scope:
```Julia
function my_function()
    @store my_local_variable = 99
    @store my_local_symbol = :hello
end

my_function()
show(st)
```


For plotting, the `storefig` functions allows to save the plot to a file (using `Plots.savefig`) and simultaneously stores its file path in the `Llama.Storage` so that the [Llama-Viewer]() can display it:
```Julia
using Plots
p = plot(rand(100), rand(100))
storefig(st, p, "my_first_plot", "results/my_plot.pdf")
```

The storage can be written to a .toml file (recommended for readability) or to a .csv file 
```Julia
write(st, "my_config.toml")
write(st, "my_config.csv")
```


