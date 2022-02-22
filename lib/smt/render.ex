defmodule Smt.Render do
  @spec render(
          Smt.Instruction.instruction()
          | Smt.Formula.formula(String.t())
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
          Smt.Instruction.instruction()
          | Smt.Formula.formula(String.t())
        ]) :: String.t()
  defp render_arguments(arguments) do
    arguments
    |> Enum.map(&render/1)
    |> Enum.join(" ")
  end
end
