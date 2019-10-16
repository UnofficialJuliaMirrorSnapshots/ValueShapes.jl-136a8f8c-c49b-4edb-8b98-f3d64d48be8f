# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).


"""
    NamedTupleShape{N,AC} <: AbstractValueShape

Defines the shape of a `NamedTuple` (resp.  set of variables, parameters,
etc.).

Constructors:

    NamedTupleShape(name1 = shape1, ...)
    NamedTupleShape(shape::NamedTuple)

e.g.

    shape = NamedTupleShape(
        a = ArrayShape{Real}(2, 3),
        b = ScalarShape{Real}(),
        c = ArrayShape{Real}(4)
    )

Use

    (shape::NamedTupleShape)(data::AbstractVector)::NamedTuple

to view a  flattened data vector as a `NamedTuple`.

    Base.Vector{T}(undef, shape::NamedTupleShape)
    Base.Vector(undef, shape::NamedTupleShape)

will create a suitable uninitialized vector of the right length to hold such
flattened data for the given shape. If no type `T` is given, a suitable non-abstract
type will be chosen automatically via `nonabstract_eltype(NamedTupleShape)`.

When dealing with multiple vectors of flattened data,

    (shape::NamedTupleShape)(
        data::ArrayOfArrays.AbstractVectorOfSimilarVectors
    )::NamedTuple

creates a view of a vector of flattened data vectors as a table with the
variable names as column names and the (possibly array-shaped) variable
value views as entries. In return,

    ArraysOfArrays.VectorOfSimilarVectors{T}(shape::NamedTupleShape)
    ArraysOfArrays.VectorOfSimilarVectors(shape::NamedTupleShape)

will create a suitable vector (of length zero) of vectors to hold flattened
value data. The result will be a `VectorOfSimilarVectors` wrapped around a
2-dimensional `ElasticArray`. Internally all data is stored in a single
flat `Vector{T}`.

Example:

```julia
shape = NamedTupleShape(
    a = ScalarShape{Real}(),
    b = ArrayShape{Real}(2, 3),
    c = ConstValueShape(42)
)
data = VectorOfSimilarVectors{Float64}(shape)
resize!(data, 10)
rand!(flatview(data))
table = TypedTables.Table(shape(data))
fill!(table.a, 4.2)
all(x -> x == 4.2, view(flatview(data), 1, :))
```
"""
struct NamedTupleShape{names,AT<:(NTuple{N,ValueAccessor} where N)} <: AbstractValueShape
    _accessors::NamedTuple{names,AT}
    _flatdof::Int

    @inline function NamedTupleShape(shape::NamedTuple{names,<:NTuple{N,AbstractValueShape}}) where {names,N}
        labels = keys(shape)
        shapes = values(shape)
        shapelengths = map(totalndof, shapes)
        offsets = _varoffset_cumsum(shapelengths)
        accessors = map(ValueAccessor, shapes, offsets)
        # acclengths = map(x -> x.len, accessors)
        # @assert shapelengths == acclengths
        n_flattened = sum(shapelengths)
        named_accessors = NamedTuple{labels}(accessors)
        new{names,typeof(accessors)}(named_accessors, n_flattened)
    end
end

export NamedTupleShape

@inline NamedTupleShape(;named_shapes...) = NamedTupleShape(values(named_shapes))


@inline Base.size(::NamedTupleShape) = ()


@inline _accessors(x::NamedTupleShape) = getfield(x, :_accessors)
@inline totalndof(x::NamedTupleShape) = getfield(x, :_flatdof)


@inline Base.keys(shape::NamedTupleShape) = keys(_accessors(shape))

@inline Base.values(shape::NamedTupleShape) = values(_accessors(shape))

@inline Base.getproperty(shape::NamedTupleShape, p::Symbol) = getproperty(_accessors(shape), p)

@inline Base.propertynames(shape::NamedTupleShape) = propertynames(_accessors(shape))

@inline Base.length(shape::NamedTupleShape) = length(_accessors(shape))

@inline Base.getindex(shape::NamedTupleShape, i::Integer) = getindex(_accessors(shape), i)

@inline Base.map(f, shape::NamedTupleShape) = map(f, _accessors(shape))


Base.@propagate_inbounds function (shape::NamedTupleShape)(data::AbstractVector)
    accessors = _accessors(shape)
    map(va -> va(data), accessors)
end

Base.@propagate_inbounds function (shape::NamedTupleShape)(data::AbstractVectorOfSimilarVectors)
    accessors = _accessors(shape)
    cols = map(va -> va(data), accessors)
    TypedTables.Table(cols)
end


@inline _multi_promote_type() = Nothing
@inline _multi_promote_type(T::Type) = T
@inline _multi_promote_type(T::Type, U::Type, rest::Type...) = promote_type(T, _multi_promote_type(U, rest...))


@inline nonabstract_eltype(shape::NamedTupleShape) =
    _multi_promote_type(map(nonabstract_eltype, values(shape))...)


Base.Vector{T}(::UndefInitializer, shape::NamedTupleShape) where T =
    Vector{T}(undef, totalndof(shape))

Base.Vector(::UndefInitializer, shape::NamedTupleShape) =
    Vector{nonabstract_eltype(shape)}(undef, totalndof(shape))


ArraysOfArrays.VectorOfSimilarVectors{T}(shape::NamedTupleShape) where T =
    VectorOfSimilarVectors(ElasticArray{T}(undef, totalndof(shape), 0))

ArraysOfArrays.VectorOfSimilarVectors(shape::NamedTupleShape) =
    VectorOfSimilarVectors(ElasticArray{nonabstract_eltype(shape)}(undef, totalndof(shape), 0))
