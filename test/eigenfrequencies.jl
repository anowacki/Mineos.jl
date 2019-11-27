using Test, Mineos, SeisModels

@testset "Eigenfrequencies" begin
    let freqs = eigenfrequencies(LinearLayeredModel(PREM), lmax=128, nmax=10)
        @test length(freqs) == 4232
        @test freqs[0,:S,0] ≈ 0.814338 atol=1e-6
        @test freqs[0,:T,7] ≈ 1.22036 atol=1e-5
        @test freqs[8,:C,44] ≈ 40.28792 atol=1e-5
    end
end