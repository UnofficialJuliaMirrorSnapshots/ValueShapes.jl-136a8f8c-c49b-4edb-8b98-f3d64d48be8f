# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).

using ValueShapes
using Test

using Random
using ElasticArrays
import TypedTables


@testset "scalar_shape" begin
    @test @inferred(ValueShapes._shapeoftype(Int)) == ScalarShape{Int}()
    @test @inferred(ValueShapes._shapeoftype(Complex{Float64})) == ScalarShape{Complex{Float64}}()

    @test @inferred(shapeof(3)) == ScalarShape{Int}()

    @test @inferred(totalndof(ScalarShape{Int}())) == 1
    @test @inferred(totalndof(ScalarShape{Complex{Float64}}())) == 2
end
