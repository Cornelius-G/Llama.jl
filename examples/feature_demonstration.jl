using LAMA 

#create a new LAMA.Storage object
st = Storage()

# store variables with the store function by explicitly passing the storage object, the variable, and the name of the value in the storage
my_first_variable = 1
store(st, my_first_variable, "my_first_variable")
store(st, my_first_variable, "copy_of_my_first_variable")
store(st, :a, "my_first_symbol")

show(st)

# set a default storage for more convenient use with the `@store` macro
import LAMA.default_storage
LAMA.default_storage() = st

# use `@store` macro to store variables in the default storage
@store my_second_variable = 2+5
@store my_third_variable = "This is a String"
@store my_array = rand(5)
@store my_symbol = :abcd
@store my_nt = (a=1, b=2)

show(st)


using Dates
@store datetime = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")

analysis_path = "results/"*datetime*"/"


# @store also works on complex/custom data types by serializing them
using BAT
@store algorithm = MetropolisHastings()

st

# also local variables can be stored (without them being added to global scope)
function my_function()
    @store my_local_variable = 99
    @store my_local_symbol = :hello
end

my_function()

show(st)


# the storage object can be written to a .toml file (recommended for readability) 
write(st, "my_config.toml")
# or to a .csv file
write(st, "my_config.csv")









# #---------------------------------------------
# using LAMA 

# st = Storage()

# my_first_variable = 1
# store(st, my_first_variable, "my_first_variable")

# my_first_symbol = :qrst
# store(st, my_first_symbol, "my_first_symbol")

# my_nt = (a=1, b=2)
# typeof(my_nt)
# store(st, my_nt, "my_nt")

# #TODO: storing Dict not working yet
# my_dict = Dict("a"=>1, "b"=>2)
# store(st, my_dict, "my_dict")

# st

# import LAMA.default_storage
# LAMA.default_storage() = st

# @store x = 1+4
# @store y = "I'm a string."
# @store z = (a=1, b=2, c="Str")
# @store u = :abcd

# function f()
#     @store xf = 1+4+8
#     @store yf = "I'm a f string."
#     @store zf = (a=41, b=42, c="f Str")
#     @store uf = :(abcdef[1])

#     println("xf: ", xf)
#     println("yf: ", yf)
#     println("zf: ", zf)
#     println("uf: ", typeof(uf))
# end 
# f()

# st


# #TODO: not working yet @store d = Dict("a"=>1, "b"=>3)
# using LAMA
# using BAT
# alg = MetropolisHastings()
# typeof(alg.weighting)

# LAMA.to_dict(alg, "alg")

# w = alg.weighting
# LAMA.to_dict(w, "w")

# nt = (a=1, b="ABC", c=(ca=11, cb="21",))
# d =LAMA.to_dict(nt, "nt")
# d["nt"]