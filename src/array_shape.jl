# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).


"""
    ArrayShape{T,N} <: AbstractValueShape

Describes the shape of `N`-dimensional arrays of type `T` and a given size.

Constructor:

    ArrayShape{T}(dims::NTuple{N,Integer}) where {T,N}
    ArrayShape{T}(dims::Integer...) where {T}

e.g.

    shape = ArrayShape{Real}(2, 3)

Array shapes can be used to instantiate arrays of the given shape, e.g.

    size(Array(undef, shape)) == (2, 3)
    size(ElasticArrays.ElasticArray(undef, shape)) == (2, 3)

If the element type of the shape of an abstract type of union,
[`ValueShapes.default_datatype`](@ref) will be used to determine a
suitable more specific type, if possible:

    eltype(Array(undef, shape)) == Float64
"""
struct ArrayShape{T,N} <: AbstractValueShape
    dims::NTuple{N,Int}
end

export ArrayShape


ArrayShape{T}(dims::NTuple{N,Integer}) where {T,N} = ArrayShape{T,N}(map(Int, dims))
ArrayShape{T}(dims::Integer...) where {T} = ArrayShape{T}(dims)


@inline Base.size(shape::ArrayShape) = shape.dims

@inline Base.eltype(::ArrayShape{T}) where {T} = T


@inline _shapeoftype(T::Type{<:AbstractArray}) = throw(ArgumentError("Type $T does not have a fixed shape"))

@inline function shapeof(x::AbstractArray{T}) where T
    _shapeoftype(T) # ensure T has a fixed shape
    ArrayShape{T}(size(x))
end

# Possible extension: shapeof(x::AbstractArrayOfSimilarArrays{...})


totalndof(shape::ArrayShape{T}) where{T} =
    prod(size(shape)) * totalndof(_shapeoftype(T))


@inline Array{U}(::UndefInitializer, shape::ArrayShape{T}) where {T,U<:T} =
    Array{U}(undef, size(shape)...)

@inline Array(::UndefInitializer, shape::ArrayShape) =
    Array{nonabstract_eltype(shape)}(undef, shape)


@inline ElasticArray{U}(::UndefInitializer, shape::ArrayShape{T}) where {T,U<:T} =
    ElasticArray{U}(undef, size(shape)...)

@inline ElasticArray(::UndefInitializer, shape::ArrayShape) =
    ElasticArray{nonabstract_eltype(shape)}(undef, shape)


# TODO: Add support for StaticArray.

# Possible extension: variable/flexible array shapes?
