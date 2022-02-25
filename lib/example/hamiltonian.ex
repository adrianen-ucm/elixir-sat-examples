defmodule Example.Hamiltonian do
  @moduledoc """
  The Hamiltonian path problem expressed as a propositional
  problem.
  """

  import Result

  @doc """
  Given a `Graph`, runs the SMT-LIB instructions for
   this problem by using an `Smt.Interpreter.Instance`.
  """
  @spec run(Graph.t(any()), module()) :: any()
  def run(graph, interpreter) do
    interpreter.with_ref(fn ref ->
      declare_variables(graph, ref)
      ~> then(assert_formulas(graph, ref))
      ~> then(Smt.check_sat(ref))
    end)
  end

  defp in_position(node, position) do
    "p_#{node}_#{position}"
  end

  defp all_node_positions(graph) do
    Stream.flat_map(Graph.nodes(graph), fn n ->
      Stream.map(1..Graph.num_nodes(graph), fn c ->
        {n, c}
      end)
    end)
  end

  defp all_different_pairs(graph) do
    Stream.flat_map(Graph.nodes(graph), fn n ->
      Graph.nodes(graph)
      |> Stream.filter(&(&1 != n))
      |> Stream.map(&{n, &1})
    end)
  end

  defp declare_variables(graph, ref) do
    all_node_positions(graph)
    |> Result.each(fn {n, p} ->
      Smt.declare(ref, in_position(n, p))
    end)
  end

  defp assert_formulas(graph, ref) do
    Stream.concat([
      node_in_position(graph),
      exclusive_position(graph),
      adjacent_positions(graph)
    ])
    |> Result.each(&Smt.assert(ref, &1))
  end

  defp node_in_position(graph) do
    Stream.map(Graph.nodes(graph), fn n ->
      {:||,
       for(
         p <- 1..Graph.num_nodes(graph),
         do: {:var, in_position(n, p)}
       )}
    end)
  end

  defp exclusive_position(graph) do
    all_different_pairs(graph)
    |> Stream.flat_map(fn {m, n} ->
      Stream.map(1..Graph.num_nodes(graph), fn p ->
        {:!,
         {:&&,
          [
            {:var, in_position(m, p)},
            {:var, in_position(n, p)}
          ]}}
      end)
    end)
  end

  defp adjacent_positions(graph) do
    all_different_pairs(graph)
    |> Stream.filter(&(not Graph.has_edge?(graph, &1)))
    |> Stream.flat_map(fn {m, n} ->
      Stream.map(1..(Graph.num_nodes(graph) - 1), fn p ->
        {:->, {:var, in_position(m, p)},
         {
           :!,
           {:var, in_position(n, p + 1)}
         }}
      end)
    end)
  end
end
