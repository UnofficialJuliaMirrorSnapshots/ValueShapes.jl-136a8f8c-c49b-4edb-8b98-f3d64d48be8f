# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).


struct ValueAccessor{S<:AbstractValueShape}
    shape::S
    offset::Int
    len::Int

    ValueAccessor{S}(shape::S, offset::Int) where {S<:AbstractValueShape} =
        new{S}(shape, offset, totalndof(shape))
end

ValueAccessor(shape::S, offset::Int) where {S<:AbstractValueShape} = ValueAccessor{S}(shape, offset)


const ScalarAccessor{T} = ValueAccessor{ScalarShape{T}} where {T}
const ArrayAccessor{T,N} = ValueAccessor{ArrayShape{T,N}} where {T,N}
const ConstAccessor = ValueAccessor{ConstValueShape{T}} where {T}


nonabstract_eltype(va::ValueAccessor) = nonabstract_eltype(va.shape)

AbstractValueShape(va::ValueAccessor) = va.shape
Base.convert(::Type{AbstractValueShape}, va::ValueAccessor) = ValueShape(va)

Base.size(va::ValueAccessor) = size(va.shape)
Base.length(va::ValueAccessor) = length(va.shape)


# ToDo: implement Base.getindex for ValueAccessor? Allow only contiguous?





@inline function _view_range(idxs::AbstractUnitRange{<:Integer}, va::ValueAccessor)
    from = first(idxs) + va.offset
    to = from + va.len - 1
    from:to
end

@inline _view_idxs(idxs::AbstractUnitRange{<:Integer}, va::ValueAccessor) = _view_range(idxs, va)
@inline _view_idxs(idxs::AbstractUnitRange{<:Integer}, va::ScalarAccessor) = first(idxs) + va.offset


Base.@propagate_inbounds (va::ScalarAccessor)(data::AbstractVector) =
    data[_view_idxs(axes(data, 1), va)]

Base.@propagate_inbounds (va::ArrayAccessor{T,1})(data::AbstractVector) where {T} =
    view(data, _view_idxs(axes(data, 1), va))

Base.@propagate_inbounds (va::ArrayAccessor{T,N})(data::AbstractVector) where {T,N} =
    reshape(view(data, _view_idxs(axes(data, 1), va)), size(va.shape)...)

@inline (va::ConstAccessor)(::AbstractVector) = va.shape.value


Base.@propagate_inbounds function (va::ScalarAccessor)(data::AbstractVectorOfSimilarVectors)
    flat_data = flatview(data)
    idxs = _view_idxs(axes(flat_data, 1), va)
    view(flat_data, idxs, :)
end

Base.@propagate_inbounds function (va::ArrayAccessor{T,1})(data::AbstractVectorOfSimilarVectors) where {T,N}
    flat_data = flatview(data)
    idxs = _view_idxs(axes(flat_data, 1), va)
    fpview = view(flat_data, idxs, :)
    VectorOfSimilarVectors(fpview)
end

Base.@propagate_inbounds function (va::ArrayAccessor{T,N})(data::AbstractVectorOfSimilarVectors) where {T,N}
    flat_data = flatview(data)
    idxs = _view_idxs(axes(flat_data, 1), va)
    fpview = view(flat_data, idxs, :)
    VectorOfSimilarArrays(reshape(fpview, size(va.shape)..., :))
end

@inline (va::ConstAccessor)(data::AbstractVectorOfSimilarVectors) =
    Fill(va.shape.value, size(data,1))


Base.@propagate_inbounds Base.getindex(data::AbstractVector, va::ValueAccessor) = va(data)


Base.@propagate_inbounds Base.view(data::AbstractVector, va::ValueAccessor) = va(data)
Base.@propagate_inbounds Base.view(data::AbstractVector{<:AbstractVector}, va::ValueAccessor) = va(data)


Base.@propagate_inbounds function Base.view(data::AbstractVector, va::ScalarAccessor)
    view(data, _view_idxs(axes(data, 1), va))
end


Base.@propagate_inbounds function Base.view(
    data::AbstractMatrix, va_row::ValueAccessor, va_col::ValueAccessor
)
    view(data, _view_idxs(axes(data, 1), va_row), _view_idxs(axes(data, 2), va_col))
end


@inline _varoffset_cumsum_impl(s, x, y, rest...) = (s, _varoffset_cumsum_impl(s+x, y, rest...)...)
@inline _varoffset_cumsum_impl(s,x) = (s,)
@inline _varoffset_cumsum_impl(s) = ()
@inline _varoffset_cumsum(x::Tuple) = _varoffset_cumsum_impl(0, x...)
