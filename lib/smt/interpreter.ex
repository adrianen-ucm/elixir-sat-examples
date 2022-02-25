defprotocol Smt.Interpreter do
  @moduledoc """
  A simple communication protocol with an
  SMT-LIB interpreter.
  """

  @doc """
  Send an SMT-LIB instruction.
  """
  @spec offer(t(), Smt.Instruction.t()) :: Result.t(nil, any())
  def offer(ref, instruction)

  @doc """
  Take a pending response from the interpreter.
  """
  @spec take(t()) :: Result.t(String.t(), any())
  def take(ref)
end
