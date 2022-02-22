defmodule Smt.Interpreter.Instance do
  @callback with_ref(
              any(),
              (Smt.Interpreter.t() -> any())
            ) :: any()

  @callback with_ref((Smt.Interpreter.t() -> any())) :: any()
end

defprotocol Smt.Interpreter do
  @spec offer(t(), Smt.Instruction.t()) :: Result.t(nil, any())
  def offer(ref, instruction)

  @spec take(t()) :: Result.t(String.t(), any())
  def take(ref)
end
