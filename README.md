# ![Elixir](https://hexdocs.pm/ex_unit/assets/logo.png) expostal

[![Build Status](https://travis-ci.org/SweetIQ/expostal.svg?branch=master)](https://travis-ci.org/SweetIQ/expostal)
[![Hex.pm](https://img.shields.io/hexpm/v/expostal.svg)](https://hex.pm/packages/expostal)
[![license](https://img.shields.io/github/license/sweetiq/expostal.svg)](https://github.com/SweetIQ/expostal/blob/master/LICENSE)

Elixir binding for [Libpostal] - a library for parsing/normalizing street addresses around the world. 
Powered by statistical NLP and open geo data.

Tutorial on how to write Elixir/Erlang NIF: http://cs.mcgill.ca/~mxia3/2017/06/18/tutorial-extending-elixir-with-c-using-NIF/

## Installation

The package can be installed by adding `expostal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:expostal, "~> 0.2.0"}
  ]
end
```
or this repo:

```elixir
def deps do
  [
    {:expostal, github: "dkuku/expostal"}
  ]
end
```
### Dependencies

Depends on [system-wide installation of libpostal](https://github.com/openvenues/libpostal#installation).

[Libpostal]: https://github.com/openvenues/libpostal

## Usage

Parsing an address:

```
iex> Expostal.parse_address("615 Rene Levesque Ouest, Montreal, QC, Canada")

%{city: "montreal", country: "canada", house_number: "615",
  road: "rene levesque ouest", state: "qc"}

```

Expanding an address:

```
iex> Expostal.expand_address("781 Franklin Ave Crown Hts Brooklyn NY")

["781 franklin avenue crown heights brooklyn new york",
  "781 franklin avenue crown heights brooklyn ny"]
```

## Documentation

View the docs on [https://hexdocs.pm/expostal](https://hexdocs.pm/expostal), or
generate the docs locally with `mix docs`.
