# Llama.jl - Llama Logs All My Analyses


<img src="icons/llama_julia.png" width="240" align="left"/>


[Llama](https://github.com/Cornelius-G/Llama) is a tool that helps you keep track of your analyses and simulations. It consists of a Logger and and Viewer.
Llama.jl is the LLama Logger for Julia and allows to generate logfiles of your analyses that can later be explored with the [Llama Viewer]().

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

The `@store` macro then allows to store variables with their name in the default storage:
```Julia
@store my_second_variable = 2+5
@store my_third_variable = "This is a String"
@store my_array = rand(5)
@store my_symbol = :abcd
@store my_nt = (a=1, b=2)
```

show(st)


### 3) Saving the storage by writing to file
The storage can be written to a .toml file (recommended for readability) or to a .csv file 
```Julia
write(st, "my_config.toml")
write(st, "my_config.csv")
```

## Further features

### Custom datatypes
The `@store` macro and the `store` function also work on complex/custom data types by performing a simple serialization in a human-readable format:
```Julia
using BAT
@store algorithm = MetropolisHastings()
```

### Plots
For plotting, the `storefig` functions allows to save the plot to a file (using `Plots.savefig`) and simultaneously stores its file path in the `Llama.Storage` so that the [Llama-Viewer]() can display it:
```Julia
using Plots
p = plot(rand(100), rand(100))
storefig(st, p, "my_first_plot", "results/my_plot.pdf")
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





