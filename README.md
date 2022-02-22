# Elixir SAT examples

Some examples of expressing problems in propositional logic and
interacting with Z3 for solving them:

- [Hamiltonian path](./lib/example/hamiltonian.ex)
- [Graph coloring](./lib/example/colors.ex)

[This script](./demo.exs) allows to try different options:

```sh
mix run demo.exs \
  -p [hamiltonian|colors] \
  -i [exile|io|porcelain|port|pure]
```

## Exile

Z3 interaction through [Exile](https://github.com/akash-akya/exile).

## IO

The SMT-LIB script is written to standard output and results are read from standard input.

## Porcelain

Z3 interaction through [Porcelain](https://github.com/alco/porcelain).

## Port

Z3 interaction through a [Port](https://hexdocs.pm/elixir/Port.html).

## Pure

It is not really pure, but an example of a process that collects the instructions and finally returns them back.
