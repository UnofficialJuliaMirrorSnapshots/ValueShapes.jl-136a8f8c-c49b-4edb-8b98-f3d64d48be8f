# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).

__precompile__(true)

module ValueShapes

using ArraysOfArrays
using ElasticArrays
using FillArrays
using MacroTools

import TypedTables

include("abstract_value_shape.jl")
include("scalar_shape.jl")
include("const_value_shape.jl")
include("array_shape.jl")
include("value_accessor.jl")
include("named_tuple_shape.jl")

end # module
