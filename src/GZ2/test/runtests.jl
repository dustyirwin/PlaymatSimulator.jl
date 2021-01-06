using GZ2
using Test

@testset "basic" begin
    global g
    @test_nowarn begin 
        g = GZ2.initgame(joinpath("..","example","BasicGame","basic.jl"))
        GZ2.quitSDL(g)
    end
    
end

@testset "basic2" begin
    @test_nowarn begin 
        g = GZ2.initgame(joinpath("..","example","BasicGame","basic2.jl"))
        GZ2.quitSDL(g)
    end
end
