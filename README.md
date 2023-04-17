# Mineos.jl

[![Build Status](https://github.com/anowacki/Mineos.jl/workflows/CI/badge.svg)](https://github.com/anowacki/Mineos.jl/actions)
[![Coverage status](https://codecov.io/gh/anowacki/Mineos.jl/branch/master/graph/badge.svg?token=knbujQ671A)](https://codecov.io/gh/anowacki/Mineos.jl)

Mineos.jl is a [Julia](https://julialang.org) wrapper around
the [Mineos](https://geodynamics.org/cig/software/mineos)
programs to compute normal modes of the Earth and similar
planets.

## Installation
In Julia, simply do
```julia
julia> import Pkg; Pkg.add("Mineos")
```

## Usage
The package relies on the [SeisModels.jl](https://github.com/anowacki/SeisModels.jl)
package to create models for computation by Mineos.  This will be
installed if you follow the instructions above.  However, to directly
use the functionality of SeisModels.jl to create models, you need to
add it to your environment using `Pkg.add("SeisModels")`.

### Calculating mode properties
This is done using the `eigenmodes` function, which accepts
a `SeisModel.LinearLayeredModel`.  For example, to compute
the frequency of ₀S₉ in PREM, ignoring toroidal modes and limiting the
calculation to a maximum angular order of 9 and radial order of 0, you can do:

```julia
julia> using Mineos, SeisModels

julia> modes = eigenmodes(LinearLayeredModel(PREM), lmax=9, nmax=0, toroidal=false, ic_toroidal=false);

julia> modes[0,:S,9].frequency
1.578258
```

`eiegenmodes` returns a type (`Mineos.Mode`) which contains the following
fields you can access:
- `type`: Type of oscillation, which is one of:
  - `:spheroidal`: Spheroidal mode
  - `:toroidal`: Toroidal mode
  - `:ic_toroidal`: Toroidal mode in the inner core
- `n`: Radial order
- `l`: Angular order
- `phase_vel`: Phase velocity of mode in km/s
- `group_vel`: Group velocity of mode in km/s
- `frequency`: Frequency of mode in mHz
- `period`: Period of mode in s
- `Q`: Attenuation of mode
- `rayleigh_quotient`: Rayleigh quotient of mode, which is the
  ratio of kinetic to potential energy minus one, which should be
  of order `eps` if the eigenfunction is accurate, where `eps` is
  the nominal error of the calculation integration scheme.

Note that you access mode _<sub>n</sub>X<sub>l</sub>_ by
`modes[n,X,l]`, where `n` is the radial order, `l` is the angular
order and `X` is `:S` for spheroidal or radial modes, `:T` for
toroidal modes and `:C` for inner core toroidal modes.  (See
that `X` is a `Symbol` and therefore needs the `:` before the character.)

See the help for `eigenmodes` for a full list of keyword arguments.

#### Quickly obtaining mode eigenfrequencies
The `eigenfrequencies` function is similar to `eigenmodes`, but only
returns eigenfrequencies for each mode in mHz.

### Eigenfunctions and synthetic seismograms
The retrieval of eigenfunctions and calculation of synthetic seismogramss
are not yet implemented, but are planned for the future.  Pull requests
adding this functionality are welcome.

## Contributions
If you find a problem with this Julia wrapper of Mineos, then please
[open an issue](https://github.com/anowacki/Mineos.jl/issues/new/choose)
with as much description as possible to recreate the error.

If you would like to contribute code which implements new functionality
or fixes bugs in Mineos.jl, please
[submit a pull request](https://github.com/anowacki/Mineos.jl/compare)
or get in touch.
