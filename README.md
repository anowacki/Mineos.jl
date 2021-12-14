# Mineos.jl

[![Build Status](https://travis-ci.org/anowacki/Mineos.jl.svg?branch=master)](https://travis-ci.org/anowacki/Mineos.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/8mhk01fra1qi7d5c?svg=true)](https://ci.appveyor.com/project/AndyNowacki/mineos-jl)
[![Coverage Status](https://coveralls.io/repos/github/anowacki/Mineos.jl/badge.svg?branch=master)](https://coveralls.io/github/anowacki/Mineos.jl?branch=master)

Mineos.jl is a [Julia](https://julialang.org) wrapper around
the [Mineos](https://geodynamics.org/cig/software/mineos)
programs to compute normal modes of the Earth and similar
planets.

## Installation
In Julia, simply do
```julia
julia> import Pkg; Pkg.pkg"add https://github.com/anowacki/Mineos.jl"
```

## Usage
The package relies on the [SeisModels.jl](https://github.com/anowacki/SeisModels.jl)
package to create models for computation by Mineos.  This will be
installed if you follow the instructions above.  However, to directly
use the functionality of SeisModels.jl to create models, you need to
add it to your environment using `Pkg.add("SeisModels")`.

### Calculating mode eigenfrequencies
This is done using the `eigenfrequencies` function, which accepts
a `SeisModel.LinearLayeredModel`.  For example, to compute
the frequency of ₀S₉ in PREM, ignoring toroidal modes and limiting the
calculation to a maximum angular order of 9 and radial order of 0, you can do:

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
