# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).

using ValueShapes
using Test

using Random
using ElasticArrays


@testset "array_shape" begin
    @test_throws ArgumentError @inferred(ValueShapes._shapeoftype(Vector{Int}))

    @test @inferred(shapeof(rand(3))) == ArrayShape{Float64,1}((3,))
    @test @inferred(shapeof(rand(3, 4, 5))) == ArrayShape{Float64,3}((3, 4, 5))

    @inferred(ValueShapes.nonabstract_eltype(ArrayShape{Complex,3}((3, 4, 5)))) == Complex{Float64}

    @test @inferred(totalndof(ArrayShape{Float64,1}((3,)))) == 3
    @test @inferred(totalndof(ArrayShape{Complex,3}((3, 4, 5)))) == 120

    @test shapeof(@inferred(Array(undef, ArrayShape{Complex,3}((3, 4, 5))))) == ArrayShape{Complex{Float64},3}((3, 4, 5))
    @test typeof(@inferred(Array(undef, ArrayShape{Complex,3}((3, 4, 5))))) == Array{Complex{Float64},3}
    @test size(@inferred(Array(undef, ArrayShape{Complex,3}((3, 4, 5))))) == (3, 4, 5)
    @test typeof(@inferred(Array{Float32}(undef, ArrayShape{Real,1}((3,))))) == Array{Float32,1}

    @test shapeof(@inferred(ElasticArray(undef, ArrayShape{Complex,3}((3, 4, 5))))) == ArrayShape{Complex{Float64},3}((3, 4, 5))
    @test typeof(@inferred(ElasticArray(undef, ArrayShape{Complex,3}((3, 4, 5))))) == ElasticArray{Complex{Float64},3,2}
    @test size(@inferred(ElasticArray(undef, ArrayShape{Complex,3}((3, 4, 5))))) == (3, 4, 5)
    @test typeof(@inferred(ElasticArray{Float32}(undef, ArrayShape{Real,2}((3,4))))) == ElasticArray{Float32,2,1}
end
