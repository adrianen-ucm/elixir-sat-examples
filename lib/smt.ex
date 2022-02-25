defmodule Smt do
  @moduledoc """
  Functions to operate with an `Smt.Interpreter`.
  """

  import Result

  @doc """
  Defines a new variable given its name.
  ## Examples
      iex> Smt.Interpreter.Pure.with_ref(&Smt.declare(&1, "x"))
      {:ok, [{:declare, "x"}]}
  """
  @spec declare(
          Smt.Interpreter.t(),
          String.t()
        ) :: Result.t(nil, any())
  def declare(interpreter, name) do
    Smt.Interpreter.offer(interpreter, {:declare, name})
  end

  @doc """
  Assert a formula.
  ## Examples
      iex> Smt.Interpreter.Pure.with_ref(&Smt.assert(&1, {:const, true}))
      {:ok, [{:assert, {:const, true}}]}
  """
  @spec assert(
          Smt.Interpreter.t(),
          Smt.Formula.t(String.t())
        ) :: Result.t(nil, any())
  def assert(interpreter, formula) do
    Smt.Interpreter.offer(interpreter, {:assert, formula})
  end

  @doc """
  Check for satisfiability.
  ## Examples
      iex> Smt.Interpreter.Pure.with_ref(&Smt.check_sat(&1))
      {:ok, [{:check_sat}]}
  """
  @spec check_sat(Smt.Interpreter.t()) :: Result.t(:sat | :unsat, any())
  def check_sat(interpreter) do
    Smt.Interpreter.offer(interpreter, {:check_sat})
    ~> then(Smt.Interpreter.take(interpreter))
    ~> map(&String.trim/1)
    ~> (fn
          # TODO improve parsing
          "sat" -> {:ok, :sat}
          "unsat" -> {:ok, :unsat}
          other -> {:error, other}
        end).()
  end

  @doc """
  Get the current model.
  ## Examples
      iex> Smt.Interpreter.Pure.with_ref(&Smt.get_model(&1))
      {:ok, [{:get_model}]}
  """
  @spec get_model(Smt.Interpreter.t()) :: Result.t(String.t(), any())
  def get_model(interpreter) do
    # TODO improve parsing
    Smt.Interpreter.offer(interpreter, {:get_model})
    ~> then(Smt.Interpreter.take(interpreter))
  end
end
