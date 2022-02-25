defmodule Example.Colors do
  @moduledoc """
  The graph coloring problem expressed as a propositional problem
  expressed as a propositional problem.
  """

  import Result

  @doc """
  Given a `Graph` and a number of colors, runs the
  SMT-LIB instructions for this problem by using an
  `Smt.Interpreter.Instance`.
  """
  @spec run(Graph.t(any()), non_neg_integer(), module()) :: any()
  def run(graph, num_colors, interpreter) do
    interpreter.with_ref(fn ref ->
      declare_variables(graph, num_colors, ref)
      ~> then(assert_formulas(graph, num_colors, ref))
      ~> then(Smt.check_sat(ref))
    end)
  end

  defp has_color(node, color) do
    "p_#{node}_#{color}"
  end

  defp all_pairs(graph, num_colors) do
    Stream.flat_map(Graph.nodes(graph), fn n ->
      Stream.map(1..num_colors, fn c ->
        {n, c}
      end)
    end)
  end

  defp declare_variables(graph, num_colors, ref) do
    all_pairs(graph, num_colors)
    |> Result.each(fn {n, c} ->
      Smt.declare(ref, has_color(n, c))
    end)
  end

  defp assert_formulas(graph, num_colors, ref) do
    Stream.concat([
      node_has_color(graph, num_colors),
      exclusive_color(graph, num_colors),
      adjacent_color(graph, num_colors)
    ])
    |> Result.each(&Smt.assert(ref, &1))
  end

  defp node_has_color(graph, num_colors) do
    Stream.map(Graph.nodes(graph), fn n ->
      {:||,
       for(
         c <- 1..num_colors,
         do: {:var, has_color(n, c)}
       )}
    end)
  end

  defp exclusive_color(graph, num_colors) do
    all_pairs(graph, num_colors)
    |> Stream.map(fn {n, c} ->
      {:->, {:var, has_color(n, c)},
       {:&&,
        for(
          d <- 1..num_colors,
          d != c,
          do: {:!, {:var, has_color(n, d)}}
        )}}
    end)
  end

  defp adjacent_color(graph, num_colors) do
    all_pairs(graph, num_colors)
    |> Stream.map(fn {n, c} ->
      {:->, {:var, has_color(n, c)},
       {:&&,
        for(
          n <- Graph.adjacent_to(graph, n),
          do: {:!, {:var, has_color(n, c)}}
        )}}
    end)
  end
end
