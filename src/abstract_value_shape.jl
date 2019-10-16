# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).


"""
    ValueShapes.default_datatype(T::Type)

Return a default specific type U that is more specific than T, with U <: T.

e.g.

    ValueShapes.default_datatype(Real) == Float64
    ValueShapes.default_datatype(Complex) == Complex{Float64}
"""
function default_datatype end

@inline default_datatype(::Type{>:Int}) = Int
@inline default_datatype(::Type{>:Float64}) = Float64
@inline default_datatype(::Type{>:Real}) = Float64
@inline default_datatype(::Type{>:Complex{Float64}}) = Complex{Float64}
@inline default_datatype(T::Type) = T



"""
    abstract type AbstractValueShape

An `AbstractValueShape` combines type and size information, the combination of
which is termed shape, here. Subtypes are defined for shapes of scalars
(see [`ScalarShape`](@ref)), arrays (see [`ArrayShape`](@ref)) and constant
values (see [`ConstValueShape`](@ref)).

Subtype of `AbstractValueShape` must support `eltype`, `size` and
[`totalndof`](@ref).
"""
abstract type AbstractValueShape end

export AbstractValueShape

# Base.size must be explicitely defined for subtypes of AbstractValueShape:
Base.size(shape::AbstractValueShape) = missing

Base.length(shape::AbstractValueShape) = prod(size(shape))

# Value shapes should behave as scalars for broadcasting:
@inline Base.Broadcast.broadcastable(shape::AbstractValueShape) = Ref(shape)


function _shapeoftype end


function shapeof end
export shapeof

@inline shapeof(x::T) where T = _shapeoftype(T)


"""
    totalndof(shape::AbstractValueShape)

Get the total number of degrees of freedom of values having the given shape.

Equivalent to the size of the array required when flattening values of this
shape into an array of real numbers, without including any constant values.
"""
function totalndof end
export totalndof


@inline nonabstract_eltype(shape::AbstractValueShape) = default_datatype(eltype(shape))
