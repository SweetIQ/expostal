# Expostal

[![Build Status](https://travis-ci.org/SweetIQ/expostal.svg?branch=master)](https://travis-ci.org/SweetIQ/expostal)

Elixir binding for [Libpostal] - a library for parsing/normalizing street addresses around the world. 
Powered by statistical NLP and open geo data.

## Installation

The package can be installed by adding `expostal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:expostal, "~> 0.1.0"}]
end
```

### Dependencies

Depends on [system-wide installation of libpostal](https://github.com/openvenues/libpostal#installation).

[Libpostal]: https://github.com/openvenues/libpostal

## Documentation

View the docs on [https://hexdocs.pm/expostal](https://hexdocs.pm/expostal), or
generate the docs locally with `mix docs`.
