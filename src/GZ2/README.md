# GZ2

[![version](https://juliahub.com/docs/GZ2/version.svg)](https://juliahub.com/ui/Packages/GZ2/tTDGf)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliahub.com/docs/GZ2/tTDGf/)
[![Build Status](https://travis-ci.org/aviks/GZ2.jl.svg?branch=master)](https://travis-ci.com/aviks/GZ2.jl)

A modified zero overhead game development framework based on GameZero.jl by Avik & Ahan Sengupta.

## Overview
The aim of this package is to remove accidental complexity from the game development process. We therefore always choose simplicity and consistency over features. The users of this package will include young programmers learning their first language, maybe moving on from Scratch. While we aim to support reasonably sophisticated 2D games, our first priority will remain learners, and their teachers.

## Running Games

Games created using GZ2 are `.jl` files that live in any directory. 
To play the games, start the Julia REPL and:

```
pkg> add GZ2

pkg> add Colors

julia> using GZ2

julia> rungame("C:\\path\\to\\game\\Spaceship\\Spaceship.jl")

```

