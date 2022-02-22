num_colors = 4

graph =
  Graph.new()
  |> Graph.add_edge({0, 1})
  |> Graph.add_edge({1, 2})
  |> Graph.add_edge({2, 0})
  |> Graph.add_edge({2, 3})

{args, [], []} =
  OptionParser.parse(
    System.argv(),
    aliases: [
      i: :interpreter,
      p: :problem
    ],
    strict: [
      interpreter: :string,
      problem: :string
    ]
  )

interpreter =
  case args[:interpreter] do
    "exile" -> Smt.Interpreter.ExileZ3
    "io" -> Smt.Interpreter.IO
    "porcelain" -> Smt.Interpreter.PorcelainZ3
    "port" -> Smt.Interpreter.PortZ3
    "pure" -> Smt.Interpreter.Pure
  end

case args[:problem] do
  "hamiltonian" -> Example.Hamiltonian.run(graph, interpreter)
  "colors" -> Example.Colors.run(graph, num_colors, interpreter)
end
|> IO.inspect()
