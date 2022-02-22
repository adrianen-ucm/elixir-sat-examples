defmodule Graph do
  @moduledoc """
  Simple undirected graph data structure.
  """

  @type value :: any()
  @type edge(value) :: {value, value}
  @opaque t(value) :: %__MODULE__{map: %{value => MapSet.t(value)}}
  defstruct map: %{}

  @doc """
  Returns an empty `Graph`.
  """
  @spec new :: t(value)
  def new do
    %__MODULE__{}
  end

  @doc """
  Returns a `MapSet` with the nodes of a `Graph`.
  ## Examples
      iex> Graph.new() |> Graph.nodes()
      #MapSet<[]>
  """
  @spec nodes(t(value)) :: MapSet.t(value)
  def nodes(graph) do
    graph.map
    |> Map.keys()
    |> MapSet.new()
  end

  @doc """
  Returns the number of nodes of a `Graph`.
  ## Examples
      iex> Graph.new() |> Graph.num_nodes()
      0
  """
  @spec num_nodes(t(value)) :: non_neg_integer()
  def num_nodes(graph) do
    graph.map
    |> Enum.count()
  end

  @doc """
  Adds a node to a `Graph`.
  ## Examples
      iex> Graph.new() |> Graph.add_node(4) |> Graph.nodes()
      #MapSet<[4]>
  """
  @spec add_node(t(value), value) :: t(value)
  def add_node(graph, n) do
    %__MODULE__{
      map:
        graph.map
        |> Map.put_new_lazy(n, &MapSet.new/0)
    }
  end

  @doc """
  Adds an edge to a `Graph`, adding also the involved nodes
  if required.
  ## Examples
      iex> Graph.new() |> Graph.add_edge({4, 2}) |> Graph.has_edge?({4, 2})
      true
  """
  @spec add_edge(t(value), edge(value)) :: t(value)
  def add_edge(graph, {i, j}) do
    %__MODULE__{
      map:
        (graph |> add_node(i) |> add_node(j)).map
        |> Map.update!(i, &MapSet.put(&1, j))
        |> Map.update!(j, &MapSet.put(&1, i))
    }
  end

  @doc """
  Returns a `MapSet` with the adjacent nodes of a given
  node in a graph.
  ## Examples
      iex> Graph.new() |> Graph.add_edge({4, 2}) |> Graph.adjacent_to(4)
      #MapSet<[2]>
  """
  @spec adjacent_to(t(value), value) :: MapSet.t(value)
  def adjacent_to(graph, n) do
    Map.get_lazy(graph.map, n, &MapSet.new/0)
  end

  @doc """
  Checks if a `Graph` contains the given edge.
  ## Examples
      iex> Graph.new() |> Graph.has_edge?({4, 2})
      false
  """
  @spec has_edge?(t(value), edge(value)) :: boolean()
  def has_edge?(graph, {m, n}) do
    graph
    |> adjacent_to(m)
    |> MapSet.member?(n)
  end
end
