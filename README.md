# Mineos.jl

[![Build Status](https://travis-ci.org/anowacki/Mineos.jl.svg?branch=master)](https://travis-ci.org/anowacki/Mineos.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/8mhk01fra1qi7d5c?svg=true)](https://ci.appveyor.com/project/AndyNowacki/mineos-jl)


Mineos.jl is a [Julia](https://julialang.org) wrapper around
the [Mineos](https://geodynamics.org/cig/software/mineos)
programs to compute normal modes of the Earth and similar
planets.

## Installation
In Julia, simply do
```julia
julia> import Pkg; Pkg.pkg"add https://github.com/anowacki/SeisModels.jl https://github.com/anowacki/Mineos.jl"
```

### Julia v1.3 and above
If you are using Julia v1.3, the Mineos programs are automatically
downloaded and installed.  Nothing else is needed.
For this reason, it is recommended to use a recent version of
Julia with Mineos.jl.

### Julia 1.2 and below
If you need to use an older version of Julia, then the Mineos
programs are not distrbuted with this package as they rely on the
[artifacts](https://julialang.github.io/Pkg.jl/dev/artifacts/)
system introduced in Julia v1.3.

Instead, you can download pre-built binaries from
[CIG](https://geodynamics.org/cig/software/mineos) or checkout and
build the [source code](https://github.com/geodynamics/mineos).  The
program `minos_bran` must then be in your search path (`$PATH` on
`sh`/`bash`, `$path` for `csh`) so that the program can be run within
the package.

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


