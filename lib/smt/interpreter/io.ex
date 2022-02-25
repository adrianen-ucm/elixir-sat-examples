defmodule Smt.Interpreter.IO do
  @moduledoc """
  The SMT-LIB script is written to standard output
  and results are read from standard input.
  """

  @behaviour Smt.Interpreter.Instance
  @opaque t() :: %__MODULE__{device: IO.device()}
  defstruct device: :stdio

  @impl Smt.Interpreter.Instance
  @spec with_ref(IO.device(), (t() -> any())) :: any()
  def with_ref(device \\ :stdio, action) do
    action.(%__MODULE__{device: device})
  end
end

defimpl Smt.Interpreter, for: Smt.Interpreter.IO do
  @spec offer(
          Smt.Interpreter.t(),
          Smt.Instruction.t()
        ) :: Result.t(nil, any())
  def offer(ref, instruction) do
    {
      IO.puts(
        ref.device,
        Smt.Render.render(instruction)
      ),
      nil
    }
  end

  @spec take(Smt.Interpreter.t()) :: Result.t(String.t(), any())
  def take(ref) do
    case IO.gets(ref.device, "") do
      {:error, e} -> {:error, e}
      :eof -> {:error, :eof}
      data -> {:ok, data}
    end
  end
end
