using Test, Mineos, SeisModels

@testset "Eigenmodes" begin
    let modes = eigenmodes(LinearLayeredModel(PREM), lmax=128, nmax=10)
        @test length(modes) == 4232

        @test first(modes) isa Pair{Tuple{Int,Symbol,Int}, Mineos.Mode{Float64}}

        @testset "Frequencies" begin
            @test modes[0,:S,0].frequency ≈ 0.814338 atol=1e-6
            @test modes[0,:T,7].frequency ≈ 1.22036 atol=1e-5
            @test modes[8,:C,44].frequency ≈ 40.28792 atol=1e-5
        end

        @testset "Orders" begin
            mode_0S0 = modes[(0,:S,0)]
            @test mode_0S0.l == mode_0S0.n == 0
            for ((n, type, l), mode) in modes
                @test mode.l == l
                @test mode.n == n
                @test if type == :T
                    mode.type == :toroidal
                elseif type == :S
                    mode.type == :spheroidal
                elseif type == :C
                    mode.type == :ic_toroidal
                else
                    false
                end
            end
        end

        @testset "10T34" begin
            mode = modes[(10,:T,34)]
            @test mode.frequency ≈ 13.15579 atol=1e-6
            @test mode.period ≈ 1000/13.15579 rtol=1e-6
            @test mode.phase_vel ≈ 15.26459 atol=1e-6
            @test mode.group_vel ≈ 5.348 atol=1e-3
            @test mode.Q ≈ 227.8324 atol=1e-4
            @test mode.rayleigh_quotient ≈ -5.747906e-9 rtol=1e-2
        end
    end
end
