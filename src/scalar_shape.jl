# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).


"""
    ScalarShape{T} <: AbstractValueShape

An `ScalarShape` describes the shape of scalar values of a given type.

Constructor:

    ScalarShape{T::Type}()

T may be an abstract type of Union, or a specific type, e.g.

    ScalarShape{Integer}()
    ScalarShape{Real}()
    ScalarShape{Complex}()
    ScalarShape{Float32}()

Scalar shapes may have a total number of degrees of freedom
(see [`totalndof`](@ref)) greater than one, e.g. shapes of complex-valued
scalars:

    totalndof(ScalarShape{Real}()) == 1
    totalndof(ScalarShape{Complex}()) == 2
"""
struct ScalarShape{T} <: AbstractValueShape end

export ScalarShape


@inline Base.eltype(shape::ScalarShape{T}) where {T} = T

@inline Base.size(::ScalarShape) = ()


@inline _shapeoftype(T::Type{<:Number}) = ScalarShape{T}()


@inline totalndof(::ScalarShape{T}) where {T <: Real} = 1

@inline function totalndof(::ScalarShape{T}) where {T <: Any}
    if @generated
        fieldtypes = ntuple(i -> fieldtype(T, i), Val(fieldcount(T)))
        field_flatlenghts = sum(U -> totalndof(_shapeoftype(U)), fieldtypes)
        l = prod(field_flatlenghts)
        quote $l end
    else
        fieldtypes = ntuple(i -> fieldtype(T, i), Val(fieldcount(T)))
        field_flatlenghts = sum(U -> totalndof(_shapeoftype(U)), fieldtypes)
        l = prod(field_flatlenghts)
        l
    end
end
