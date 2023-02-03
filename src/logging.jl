mutable struct Storage
    dt::Dict
end
export Storage

Storage() = Storage(Dict())


import Base.show
function Base.show(io::IO, st::Storage)
    l = length(st.dt)
    #n = sizeof(st.dt) #TODO: this is not the correct number of all elements in nested dicts
    println(io, "LAMAS.Storage with $l top-level entries:");
    TOML.print(io, st.dt)
end 


isa_TOML_value(x::Any) = false
isa_TOML_value(x::Union{AbstractVector, AbstractDict, Dates.DateTime, Dates.Time, Dates.Date, Bool, Integer, AbstractFloat, AbstractString}) = true   


#---- store function -----------------------------------------------------------

"""
    store(st::Storage, x::Any, n::String)

A function that stores the value of `x` in a `Storage` object with name `n`.
The function returns `nothing`.

## Example

```julia
julia> st = Storage()
Storage(Dict{Any,Any}())

julia> x = 10
10

julia> store(st, x, "x")
nothing

julia> st.dt
Dict{Any,Any} with 1 entry:
  "x" => 10
"""

function store(st::Storage, x::Any, n::String)
    d = make_dict(x, n)
    st.dt[n] = d[n]
    return nothing
end

function store(st::Storage, x::Symbol, n::String)
    s = ":"*string(x)
    st.dt[n] = s
    return nothing
end 

function store(st::Storage, x::Expr, n::String)
    s = ":("*string(x)*")"
    st.dt[n] = s
    return nothing
end 

export store


#---- store macro --------------------------------------------------------------
function default_storage()
    throw(
        ArgumentError(
        "No default LAMA.Storage object provided. Overload the function \'default_storage\' by doing:
        import LAMA.default_storage    
        st = Storage()
        LAMA.default_storage() = st ")
    )
end

"""
    macro store(var)

A macro that stores the value of `var` in the default `Storage` object with the name of the variable "var".
The macro returns the evaluated expression.
A default `Storage` object needs to be provided by implementing the `Llama.default_storage` function.

## Example

```julia
julia> import LAMA.default_storage
julia> st = Storage()
julia> LAMA.default_storage() = st

julia> @store x = 10
10

julia> st.dt
Dict{Any,Any} with 1 entry:
  "x" => 10
"""
macro store(var)
    parent_module = __module__
    d = make_dict(var, parent_module)

    st = default_storage()
    merge!(st.dt, d)

    return esc(:($var))    
end
export @store



function make_dict(var, name::String)
    return Dict(name => to_dict(var, name))
end

function make_dict(var, m)
    @capture(var, a_ = b_)
    return Dict(String(a) => to_dict(m.eval(b), String(a)))
end



function to_dict(x, above)
    dc = Dict()
    fns = fieldnames(typeof(x))

    if length(fns) == 0
        if isa_TOML_value(x)
            return x
        elseif isa(x, Union{Symbol, Expr})
            return repr(x)
        else
            return string(Base.typename(typeof(x)).wrapper)
        end
    else 
        tn = Base.typename(typeof(x)).wrapper
        #dc[string(above)] = string(tn)
        dc["⟪Type⟫"] = string(tn)
        for f in fns
            dc[string(f)]=to_dict(getfield(x, f), string(f)) #recursive call
        end
    end

    return dc
end

#----- storefig ----------------------------------------------------------------
#TODO: add option to store .png and .pdf simultaneously

"""
    storefig(st::Storage, p, name::String, path::String) 

This function stores the file path of a given plot `p` in a given `Storage` instance, and saves the plot to a specified file path.

The function takes four arguments:
- `st` is a `Storage` instance where the name of the plot and its file path will be stored.
- `p` is the plot to be stored and saved.
- `name` is a string representing the name under which the file path will be stored in `st`.
- `path` is a string representing the file path where the plot will be saved.

## Example

```julia
julia> st = Storage()
julia> p = plot(rand(10))
julia> storefig(st, p, "random_plot", "random_plot.png")
```
"""
function storefig(st::Storage, p, name::String, path::String)
    store(st, path, name)
    _plots_module().savefig(p, path)
end
export storefig

#----- write LAMA.Storage to .toml or .csv -------------------------------------
import Base.write
"""
    Base.write(`st::Storage`, `path::String`)

Writes the data contained in the `Storage` object `st` to the file specified by `path`. The type of file format is determined by the file extension of `path`.

# Arguments:
    `st::Storage`: A `Storage` object containing the data to be written to the file.
    `path::String` : The file path to which the data will be written

# Returns:
    None

# Note:
    - If the file path ends with ".toml", the data will be written in TOML format to the file.
    - If the file path ends with ".csv", the data will be written in CSV format to the file
"""
function Base.write(st::Storage, path::String)
    if endswith(path, ".toml")
        open(path, "w") do io
            TOML.print(io, st.dt)
        end
    elseif endswith(path, ".csv")
        df = DataFrame()
        push!(df, st.dt, cols=:union)
        CSV.write(path, df)
    end
end 


"""
    flatten_dict(d::Dict; delimiter::String = ".")
    
This function flattens a nested `Dict` by concatenating keys separated by a specified delimiter.

The function takes a single mandatory argument:
- `d`, a `Dict` to be flattened.

The function also takes an optional keyword argument:
- `delimiter`, a string specifying the delimiter to use when concatenating keys. Default is delimiter=".".

## Example

```julia
julia> d = Dict("a" => Dict("b" => 1, "c" => 2), "d" => 3)
julia> flatten_dict(d, delimiter="_")
Dict{String,Any} with 3 entries:
  "a_b" => 1
  "d"  => 3
  "a_c" => 2
```
"""
function flatten_dict(d::Dict; delimiter::String = ".")
    result = Dict()
    stack = Vector{Any}([(key, value) for (key, value) in d])
    while !isempty(stack)
        key, value = pop!(stack)
        if typeof(value) <: Dict
            for (subkey, subvalue) in value
                if subkey == "⟪Type⟫"
                    push!(stack, (string(key), subvalue))
                else 
                    push!(stack, (string(key, delimiter, subkey), subvalue))
                end
            end
        else
            result[key] = value
        end
    end
    return result
end


"""
    remove_nested(d::Dict, level; delimiter::String = ".")

Takes a dictionary `d` and removes the key-value pairs whose keys have more than `level` number of `delimiter` separators.

# Arguments:
    `d::Dict`: A dictionary from which the key-value pairs needs to be removed.
    `level::Integer`: The maximum allowed number of delimiter separators in the keys.
    `delimiter::String`: The separator used in the key. (default: ".")

# Returns:
    A dictionary with the key-value pairs removed whose keys have more than `level` number of `delimiter` separators.
"""
function remove_nested(d::Dict, level; delimiter::String = ".")
    for (key, value) in d
        if count(delimiter, key) > level
            delete!(d, key)
        end
    end
    return d
end



"""
    select_from_dict(d; selection=String[], remove=String[]) 
    
This function selects or removes specific keys from a dictionary `d`.

The function takes two optional keyword arguments, `selection` and `remove`, which are both arrays of strings representing the keys to be selected or removed from the dictionary, respectively.
If `selection` is provided and not empty, the function returns a new dictionary containing only the key-value pairs whose keys are included in `selection`.
If `remove` is provided and not empty, the function removes all key-value pairs from the dictionary whose keys are included in `remove`.
"""
function select_from_dict(d; selection=String[], remove=String[])
    if !isempty(selection)
        d = filter(p -> p[1] in selection , d)
    end

    if !isempty(remove)
        [delete!(d, key) for key in remove]
    end
end



"""
    prepare_dict(d; delimiter = ".", levels=Inf, selection=String[], remove=String[]) 
    
This function prepares a nested dictionary `d` for saving to .toml or .csv.

The function first flattens the dictionary `d` using the delimiter `delimiter`. The default delimiter is `"."`.
Next, the function removes nested elements of the dictionary and keeps the specified number of levels `levels`. 
By default, `levels=Inf`, meaning all nested elements will be kept.
Finally, the function selects or removes specific keys from the dictionary using the `selection` and `remove` keyword arguments.

The function returns the prepared dictionary.
"""
function prepare_dict(d; delimiter = ".", levels=Inf, selection=String[], remove=String[])
    flat_d = flatten_dict(d, delimiter=delimiter)
    flat_d = remove_nested(flat_d, levels, delimiter=delimiter)
    flat_d = select_from_dict(flat_d; selection=selection, remove=remove)

    return flat_d
end 




#----- collect multiple .toml or .csv files and write into one .csv file -------
#TODO: allow to sort order

"""
    collect_csv(filenames, outputpath; delimiter = ".", levels=Inf, selection=String[], remove=String[]) 
    
This function collects data from multiple sources, `.toml` and `.csv` files, and saves the combined data to a `.csv` file.

The function takes two mandatory arguments:
- `filenames`, an array of strings representing the filenames of the data sources to be collected.
- `outputpath`, a string representing the file path where the combined data will be saved.

The function also takes four optional keyword arguments:
- `delimiter`, a string specifying the delimiter to use when flattening nested dictionaries.
- `levels`, a number specifying the maximum number of nested levels to parse.
- `selection`, an array of strings representing the keys to be selected from all available keys.
- `remove`, an array of strings representing the keys to be removed from the result.

The function then writes the combined data to the specified `outputpath` in `.csv` format.

## Example

```julia
julia> filenames = ["file1.toml", "file2.csv"]
julia> collect_csv(filenames, "output.csv", selection=["a", "c"])
````
"""
function collect_csv(filenames, outputpath; delimiter = ".", levels=Inf, selection=String[], remove=String[])
    df = DataFrame()

    for fn in filenames
        if  endswith(fn, ".toml")
            dt = TOML.parsefile(fn)
            flat_dt = prepare_dict(dt, delimiter = delimiter, levels=levels, selection=selection, remove=remove)
            push!(df, flat_dt, cols=:union)

        elseif endswith(fn, ".csv") # TODO: allow selections for .csv dicts
            df2 = DataFrame(CSV.File(fn))
            append!(df, df2, cols=:union)
        end
    end

    CSV.write(outputpath, df)
end 
export collect_csv



