# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).

using ValueShapes
using Test

using Random
using ElasticArrays
import TypedTables


@testset "const_value_shape" begin
    @inferred(size(ConstValueShape(42))) == ()
    @inferred(eltype(ConstValueShape(42))) == Int
    @inferred(totalndof(ConstValueShape(42))) == 0

    @inferred(size(ConstValueShape(rand(2,3)))) == (2,3)
    @inferred(eltype(ConstValueShape(rand(Float32,2,3)))) == Float32
    @inferred(totalndof(ConstValueShape(rand(2,3)))) == 0
end
