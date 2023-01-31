st = Storage()

@testset "store function" begin
    # store variables with the store function by explicitly passing the storage object, the variable, and the name of the value in the storage
    my_first_variable = 1
    store(st, my_first_variable, "my_first_variable")
    store(st, my_first_variable, "copy_of_my_first_variable")
    store(st, :a, "my_first_symbol")

    @test my_first_variable == 1
    @test st.dt["my_first_variable"] == 1
    @test st.dt["copy_of_my_first_variable"] == 1
    @test st.dt["my_first_symbol"] == ":a"
end

# set a default storage for more convenient use with the `@store` macro
import LAMA.default_storage
LAMA.default_storage() = st

# use `@store` macro to store variables in the default storage
@testset "@store macro" begin
    @store my_second_variable = 2+5
    @store my_third_variable = "This is a String"
    @store my_array = [0.1, 0.2, 0.3, 0.4, 0.5]
    @store my_symbol = :abc
    @store my_nt = (a=1, b=2)

    # test if variables are defined in main scope
    @testset "@store macro - test if defined" begin
        @test my_second_variable == 7
        @test my_third_variable == "This is a String"
        @test my_array == [0.1, 0.2, 0.3, 0.4, 0.5]
        @test my_symbol == :abc
        @test my_nt == (a=1, b=2)
    end

    @testset "@store macro - test if stored" begin
        # test if variables are stored in storage
        @test st.dt["my_second_variable"] == 7
        @test st.dt["my_third_variable"] == "This is a String"
        @test st.dt["my_array"] == [0.1, 0.2, 0.3, 0.4, 0.5]
        @test st.dt["my_symbol"] == ":abc"
        @test st.dt["my_nt"] == Dict{Any, Any}("my_nt" => "NamedTuple", "b" => 2, "a" => 1)
    end

    @testset "@store macro - local variables" begin
        # test that `@store` macro works for local variables and doesn't add them to global scope

        function my_f()
            @store my_f_x = 5
            @store my_f_y = :xyz
        end
        
        my_f()
        
        @test st.dt["my_f_x"] == 5
        @test st.dt["my_f_y"] == ":xyz"
        @test (@isdefined my_f_x) == false
        @test (@isdefined my_f_y) == false
    end
end 









# using LAMA
# import LAMA.default_storage
# st = Storage()
# LAMA.default_storage() = st


# @store my_second_variable = 2+5
# @store my_symbol = :abc

# st.dt

# my_second_variable
# my_symbol





# using MacroTools
# function myg(var)
#     @capture(var, a_ = b_)
#     println("var: ", var)

#     return esc(:($var))
# end 

# macro newstore(var)
#     d = myg(var)
#     return d
# end

# @newstore mys2 = :huhu
# @newstore myi2 = 5+6

# function myf()
#     @newstore myx = 5
# end

# mys2
# myi2

# myf()

# myx
