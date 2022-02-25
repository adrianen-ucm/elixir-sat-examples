defmodule Result do
  @moduledoc """
  A `Result` type and some utilities to deal with it.
  """

  @type error :: any()
  @type success :: any()
  @type t(success, error) :: {:ok, success} | {:error, error}

  @doc """
  A pipe operator that takes a `Result` and a partially
  applied function whic is executed with the result
  as its first argument only if the first one succeeds:

      iex> {:ok, 2} ~> (fn n -> {:error, n} end).()
      {:error, 2}

  The right operand can be surrounded with `then` and contain
  some code that produces also a `Result` and is executed only
  if the first one succeeds:

      iex> {:error, :happened} ~> then({:ok, :not_happened})
      {:error, :happened}

  It also can be surrounded with map to just lift a function
  into is success branch:

      iex> {:ok, 2} ~> map((fn n -> n + 2 end))
      {:ok, 4}
  """
  defmacro left ~> {:then, _, [b]} do
    quote do
      case unquote(left) do
        {:ok, _} -> unquote(b)
        {:error, e} -> {:error, e}
      end
    end
  end

  defmacro left ~> {:map, _, [f]} do
    quote do
      case unquote(left) do
        {:ok, v} -> {:ok, unquote(f).(v)}
        {:error, e} -> {:error, e}
      end
    end
  end

  defmacro left ~> {f, m, a} do
    quote do
      case unquote(left) do
        {:ok, v} -> unquote({f, m, [{:v, [], Result} | a]})
        {:error, e} -> {:error, e}
      end
    end
  end

  @doc """
  Performs computations that produce a `Result` in
  sequence and accumulating some value. It stops executing
  them if an error is returned.
  """
  @spec reduce(
          Enum.t(),
          Enum.acc(),
          (Enum.element(), Enum.acc() -> t(Enum.acc(), error()))
        ) :: {:error, any()} | {:ok, Enum.acc()}
  def reduce(items, acc, step) do
    case Enum.at(items, 0) do
      nil ->
        {:ok, acc}

      item ->
        case step.(item, acc) do
          {:ok, acc} -> reduce(Stream.drop(items, 1), acc, step)
          {:error, e} -> {:error, e}
        end
    end
  end

  @doc """
  Performs computations that produce a `Result` in
  sequence and stops executing them if an error is
  returned.
  """
  @spec each(
          Enum.t(),
          (Enum.element() -> t(nil, error()))
        ) :: {:error, any()} | {:ok, nil}
  def each(items, step) do
    case Enum.at(items, 0) do
      nil ->
        {:ok, nil}

      item ->
        case step.(item) do
          {:ok, _} -> each(Stream.drop(items, 1), step)
          {:error, e} -> {:error, e}
        end
    end
  end
end
