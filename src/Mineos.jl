"""
# Mineos

The Julia `Mineos` module provides an interface to computing normal
mode eigenfrequencies using the Mineos software.

# List of functions
- `eigenmodes`: Compute normal mode properties for a range of radial
  and angular orders for a 1D model of the Earth
- `eigengfrequencies`: Like `eigenmodes`, but just return eigenfrequencies.
"""
module Mineos

export
    eigenfrequencies,
    eigenmodes

using DataStructures: OrderedDict

using SeisModels: LinearLayeredModel, write_mineos
using Mineos_jll: minos_bran

const MODE_TYPE_MAPPING = Dict(
    "c" => :ic_toroidal,
    "s" => :spheroidal,
    "t" => :toroidal,
)

"""
    Mode

Struct holding the output parameters of an eigenmode calculation
obtained via a call to [`eigenmodes`](@ref).

# Fields
The following fields are accessible and should be accessed via
usual calls to `getproperty`:
- `type`: Type of oscillation:
  - `:spheroidal`: Spheroidal mode
  - `:toroidal`: Toroidal mode
  - `:ic_toroidal`: Toroidal mode in the inner core
- `n`: Radial order
- `l`: Angular order
- `phase_vel`: Phase velocity of mode in km/s
- `group_vel`: Group velocity of mode in km/s
- `frequency`: Freequency of mode in mHz
- `period`: Period of mode in s
- `Q`: Attenuation of mode
- `rayleigh_quotient`: Rayleigh quotient of mode, which is the
  ratio of kinetic to potential energy minus one, which should be
  of order `eps` if the eigenfunction is accurate, where `eps` is
  the nominal error of the calculation integration scheme.
"""
struct Mode{T}
    type::Symbol
    n::Int
    l::Int
    phase_vel::T
    group_vel::T
    frequency::T
    period::T
    Q::T
    rayleigh_quotient::T
end

Mode(; type, n, l, phase_vel, group_vel, frequency, period, Q, rayleigh_quotient) =
    Mode(type, n, l, phase_vel, group_vel, frequency, period, Q, rayleigh_quotient)

"""
    eigenfrequencies(m::LinearLayeredModel, freq=1.0; kwargs...) -> freqs

Compute the eigenfrequencies of normal modes for the model `m`.
`m` must be a `LinearLayeredModel` from `SeisModels`.

Eigenfrequencies are returned as an `OrderedDict` where the keys are
a tuple of the radial order ``n``, mode type (`:S` for spheroidal, `:T`
for toroidal, `:C` for inner core toroidal), and angular order ℓ.

For example, to retrieve ₀S₂, do `freqs[(0,:S,2)]`, and for ₃T₈ write
`freqs[(3,:T,8)]`.  The syntax `freqs[3,:T,8]` is also allowed.

### Keyword arguments
#### Mode selection
- `radial=true`: Calculate (or not) radial modes.  In this case, `nmin`
  and `nmax` are ignored.
- `spheroidal=true`: Calculate (or not) spheroidal modes.
- `toroidal=true`: Calculate (or not) toroidal modes.
- `ic_toroidal=true`: Calculate (or not) inner core toroidal modes.
#### Calculation parameters
- `eps=1e-10`: Accuracy of the integration scheme.  Eigenfrequencies are
  accurate relatively to about `2eps` to `3eps`.  `eps` can be `1e-7` for
  frequencies less than 100 mHz (periods over 10 s); for frequencies of
  100 to 200 mHz (periods 5 to 10 s), `eps` should be between `1e-12` and
  `1e-10`.
- `wgrav=10`: Frequency in mHz above which gravitational terms are neglected.
- `lmin=1`, `lmax=20`: Minimum and maximum angular order of modes.
- `wmin=0.0`, `wmax=166.0`: Minimum and maximum mode eigenfrequencies
  to consider.
- `nmin=0`, `nmax=10`: Minimum and maximum dispersion branch numbers to
  compute.
"""
function eigenfrequencies(m::LinearLayeredModel, freq=1.0; kwargs...)
    modes = eigenmodes(m, freq; kwargs...)
    OrderedDict(k=>v.frequency for (k, v) in modes)
end

"""
    eigenmodes(m::LinearLayeredModel, freq=1.0; kwargs...) -> modes

Compute the eigenmodess for the model `m`.
`m` must be a `LinearLayeredModel` from `SeisModels`.

Eigenmodes are returned as an `OrderedDict` where the keys are
a tuple of the radial order ``n``, mode type (`:S` for spheroidal, `:T`
for toroidal, `:C` for inner core toroidal), and angular order ℓ.
The values are [`Mineos.Mode`](@ref)s; see [`Mineos.Mode`](@ref)
for details of which fields contain which information.

For example, to retrieve ₀S₂, do `modes[(0,:S,2)]`, and for ₃T₈ write
`modes[(3,:T,8)]`.  The syntax `modes[3,:T,8]` is also allowed.

### Keyword arguments
#### Mode selection
- `radial=true`: Calculate (or not) radial modes.  In this case, `nmin`
  and `nmax` are ignored.
- `spheroidal=true`: Calculate (or not) spheroidal modes.
- `toroidal=true`: Calculate (or not) toroidal modes.
- `ic_toroidal=true`: Calculate (or not) inner core toroidal modes.
#### Calculation parameters
- `eps=1e-10`: Accuracy of the integration scheme.  Eigenfrequencies are
  accurate relatively to about `2eps` to `3eps`.  `eps` can be `1e-7` for
  frequencies less than 100 mHz (periods over 10 s); for frequencies of
  100 to 200 mHz (periods 5 to 10 s), `eps` should be between `1e-12` and
  `1e-10`.
- `wgrav=10`: Frequency in mHz above which gravitational terms are neglected.
- `lmin=1`, `lmax=20`: Minimum and maximum angular order of modes.
- `wmin=0.0`, `wmax=166.0`: Minimum and maximum mode eigenfrequencies
  to consider.
- `nmin=0`, `nmax=10`: Minimum and maximum dispersion branch numbers to
  compute.
"""
function eigenmodes(m::LinearLayeredModel, freq=1.0;
        # Which modes to calculate
        radial=true, toroidal=true, spheroidal=true, ic_toroidal=true,
        # Mineos calculation parameters
        eps=1e-10, wgrav=10, lmin=1, lmax=20, wmin=0.0, wmax=166.0,
        nmin=0, nmax=10)
    out = OrderedDict{Tuple{Int,Symbol,Int}, Mode{Float64}}()
    for (jcom, mode_type) in enumerate((:radial, :toroidal, :spheroidal, :ic_toroidal))
        mode_type === :radial && !radial && continue
        mode_type === :toroidal && !toroidal && continue
        mode_type === :spheroidal && !spheroidal && continue
        mode_type === :ic_toroidal && !ic_toroidal && continue
        mktempdir() do dir
            cd(dir) do
                model_in = "model.in"
                model_out = "model.out"
                eigfuncs = "eigenfunctions.out"
                control = "control"
                open(control, "w") do f
                    println(f, """
                        $model_in
                        $model_out
                        $eigfuncs
                        $eps $wgrav
                        $jcom
                        $lmin $lmax $wmin $wmax $nmin $nmax
                        """)
                end
                write_mineos(model_in, m, freq)
                output = @static if VERSION < v"1.6"
                    minos_bran() do minos_bran_path
                        String(read(pipeline(control, `$minos_bran_path`)))
                    end
                else
                    String(read(pipeline(control, `$(minos_bran())`)))
                end
                _check_minos_bran_stdout(output)
                modes = read_eigenmodes(model_out)
                _check_minos_bran_rayleigh_quotient(modes, eps, mode_type, scale=10)
                sym = mode_type in (:radial, :spheroidal) ? :S :
                      mode_type === :toroidal ? :T :
                      :C
                for (k, mode) in modes
                    out[(k[1],sym,k[2])] = mode
                end
            end
        end
    end
    out
end

"""
    read_eigenmodes(file) -> modes

Return the set of eigenmodes for a single Mineos model
output file, as produced by the `minos_bran` program.

These are contained in a Dictionary whose keys are tuples
of the angular and radial order of the mode and whose values
are [`Mineos.Mode`](@ref)s containing the calculation output.

For example, to access the ₀S₂ output, ask for
`modes[(0,2)]`.  To get the frequency in mHz, do `modes[(0,2)].frequency`.
"""
function read_eigenmodes(file, type=nothing)
    modes = OrderedDict{Tuple{Int,Int},Mode{Float64}}()
    open(file, "r") do f
        lines = readlines(f)
        iline_modes = findfirst(x->occursin(r"^\s*mode", x), lines)
        iline_modes === nothing &&
            error("cannot find mode header line in output file")
        iline_modes += 2
        while iline_modes <= length(lines)
            mode_line = lines[iline_modes]
            if isempty(mode_line)
                iline_modes += 1
                continue
            end
            !isempty(mode_line) && length(mode_line) < 108 &&
                error("line $iline_modes is too short")
            radial_order = parse(Int, mode_line[1:5])
            # Check on output mode type if requested
            mode_type = strip(mode_line[6:7])
            if type !== nothing
                mode_type == type ||
                    error("mode type in file is $mode_type, but expecting $type")
            end
            angular_order = parse(Int, mode_line[8:12])
            phase_vel = parse(Float64, mode_line[13:28])
            frequency = parse(Float64, mode_line[29:44])
            period = parse(Float64, mode_line[45:60])
            group_vel = parse(Float64, mode_line[61:76])
            Q = parse(Float64, mode_line[77:92])
            rayleigh_quotient = parse(Float64, mode_line[93:108])
            modes[(radial_order, angular_order)] = Mode(;
                n=radial_order, l=angular_order,
                type=_get_mode_type_symbol(mode_type),
                phase_vel=phase_vel,
                frequency=frequency, period=period, group_vel=group_vel,
                Q=Q, rayleigh_quotient=rayleigh_quotient
            )
            iline_modes += 1
        end
    end
    modes
end

function _check_minos_bran_stdout(out)
    lines = split(chomp(out), '\n')
    length(lines) == 12 ||
        error("unexpected output from `minos_bran`:\n$out")
end

"Ensure that the Rayleigh quotient is similar to eps,
and warn about modes for which this is not true."
function _check_minos_bran_rayleigh_quotient(modes, eps, mode_type; scale=5)
    for (k, v) in modes
        if v.rayleigh_quotient > scale*eps
            mode_name = if mode_type in (:radial, :spheroidal)
                "S"
            elseif mode_type === :toroidal
                "T"
            else
                "C"
            end
            mode_name = "$(k[1])$(mode_name)$(k[2])"
            @warn("Rayleigh quotient greater than $(scale)*eps for $mode_name")
        end
    end
end

"""
    _get_mode_type_symbol(str) -> ::Symbol

Given the letter code `str` used by `mineos`, return the `Symbol`
which is used by this module to refer to the mode type.
"""
_get_mode_type_symbol(str::AbstractString) = MODE_TYPE_MAPPING[str]

end # module
