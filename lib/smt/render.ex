defmodule Smt.Render do
  @moduledoc """
  Render SMT-LIB code.
  """

  @doc """
  Render an `Smt.Instruction` or an `Smt.Formula`
  into SMT-LIB code.
  ## Examples
      iex> Smt.Render.render({:assert, {:->, {:const, false}, {:var, :x}}})
      "(assert (=> false x))"

      iex> Smt.Render.render({:&&, [{:var, :x}, {:var, :y}, {:var, :z}]})
      "(and x y z)"
  """
  @spec render(
          Smt.Instruction.t()
          | Smt.Formula.t(String.t())
        ) :: String.t()
  def render(instruction) do
    case instruction do
      {:check_sat} -> "(check-sat)"
      {:get_model} -> "(get-model)"
      {:declare, name} -> "(declare-const #{name} Bool)"
      {:assert, formula} -> "(assert #{render(formula)})"
      {:const, true} -> "true"
      {:const, false} -> "false"
      {:var, name} -> name
      {:!, formula} -> "(not #{render(formula)})"
      {:->, a, b} -> "(=> #{render(a)} #{render(b)})"
      {:&&, formulas} -> "(and #{render_arguments(formulas)})"
      {:||, formulas} -> "(or #{render_arguments(formulas)})"
    end
  end

  @spec render_arguments([
          Smt.Instruction.t()
          | Smt.Formula.t(String.t())
        ]) :: String.t()
  defp render_arguments(arguments) do
    arguments
    |> Enum.map(&render/1)
    |> Enum.join(" ")
  end
end
