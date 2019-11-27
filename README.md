# Mineos.jl

Mineos.jl is a [Julia](https://julialang.org) wrapper around
the [Mineos](https://geodynamics.org/cig/software/mineos)
programs to compute normal modes of the Earth and similar
planets.

## Installation
### Mineos programs
Currently, the user is required to have the following programs
in their search path (i.e., `$PATH` in `sh`):
- `minos_bran`

Therefore, one must download and install the Mineos package
manually.  You can [download tarballs for your system](https://geodynamics.org/cig/software/mineos)
or clone the [Git repo](https://github.com/geodynamics/mineos)
and build yourself.

### This package
In Julia, simply do
```julia
julia> import Pkg; Pkg.pkg"add https://github.com/anowacki/SeisModels.jl https://github.com/anowacki/Mineos.jl"
```

## Usage
The package relies on the [SeisModels.jl](https://github.com/anowacki/SeisModels.jl)
package to create models for computation by Mineos.  This will be
installed if you follow the instructions above.

### Calculating mode eigenfrequencies
This is done using the `eigenfrequencies` function, which accepts
a `SeisModel.LinearLayeredModel`.  For example, to compute
the frequency of ₀S₉ in PREM, ignoring toroidal modes and limiting the
calculation toa maximum angular order of 9 and radial order of 0, you can do:

```julia
julia> using Mineos, SeisModels

julia> freqs = eigenfrequencies(LinearLayeredModel(PREM), lmax=9, nmax=0, toroidal=false, ic_toroidal=false);

julia> freqs[0,:S,9]
1.578258

```

Note that you access mode _<sub>n</sub>X<sub>l</sub>_ by
`freqs[n,X,l]`, where `n` is the radial order, `l` is the angular
order and `X` is `:S` for spheroidal or radial modes, `:T` for
toroidal modes and `:C` for inner core toroidal modes.  (See
that `X` is a `Symbol` and therefore needs the `:` before the character.)

See the help for `eigenfrequencies` for a full list of keyword arguments.


