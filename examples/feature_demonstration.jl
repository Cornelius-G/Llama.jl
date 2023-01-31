using Llama

#create a new LlAMA.Storage object to hold all the stored key-value pairs.
st = Storage()

# use the `store` function to store a variable by explicitly passing the storage object, 
# the variable, and the name of the value in the storage:
my_first_variable = 1
store(st, my_first_variable, "my_first_variable")
store(st, my_first_variable, "also_my_first_variable") # save the same value with a different name
store(st, :a, "my_first_symbol") 

show(st)

# For even more convenient usage with the `@store` macro, a default storage object needs to be defined:
import Llama.default_storage
Llama.default_storage() = st

# use `@store` macro to store variables with their name in the default storage:
@store my_second_variable = 2+5
@store my_third_variable = "This is a String"
@store my_array = rand(5)
@store my_symbol = :abcd
@store my_nt = (a=1, b=2)

show(st)

#Hint: It can often be useful to store the date and time of code execution:
using Dates
@store datetime = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")


# The `@store` macro and the `store` function also work on complex/custom data types 
# by performing a simple serialization in a human-readable format:
using BAT
@store algorithm = MetropolisHastings()

show(st)

# Also local variables can be stored with the `@store` macro, of course 
# without them being added to global scope:
function my_function()
    @store my_local_variable = 99
    @store my_local_symbol = :hello
end

my_function()
show(st)

try 
    println(my_local_variable)
catch 
    println("Variable 'my_local_variable' is not defined in global scope.")
end

# For plotting, the `storefig` functions allows to save the plot to a file (using `savefig`)
# and simultaneously stores its file path in the `Storage` so that the Llama-Viewer can display it:
using Plots
p = plot(sin.(rand(100)))
storefig(st, p, "my_first_plot", "results/my_plot.pdf")

# the storage object can be written to a .toml file (recommended for readability) 
write(st, "my_config.toml")
# or also to a .csv file
write(st, "my_config.csv")

show(st)


