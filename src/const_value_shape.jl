# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).


"""
    ConstValueShape{T} <: AbstractValueShape

A `ConstValueShape` describes the shape of constant values of type `T`.

Constructor:

    ConstValueShape(value)

`value` may be of arbitrary type, e.g. a constant scalar value or array:

    ConstValueShape(4.2),
    ConstValueShape([11 21; 12 22]),

Shapes of constant values have zero degrees of freedom
((see [`totalndof`](@ref)).
"""
struct ConstValueShape{T} <: AbstractValueShape
    value::T
end

export ConstValueShape


@inline Base.size(shape::ConstValueShape) = size(shape.value)

@inline Base.eltype(shape::ConstValueShape) = eltype(shape.value)

@inline totalndof(::ConstValueShape) = 0
