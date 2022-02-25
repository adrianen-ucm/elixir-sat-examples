defmodule Smt.Interpreter.PorcelainZ3 do
  @moduledoc """
  Z3 interaction through `Porcelain`.
  """

  @behaviour Smt.Interpreter.Instance
  @opaque t() :: %__MODULE__{proc: Porcelain.Process.t()}
  defstruct [:proc]

  @impl Smt.Interpreter.Instance
  @spec with_ref(nil, (t() -> any())) :: any()
  def with_ref(_ \\ nil, action) do
    ref = %__MODULE__{
      proc:
        Porcelain.spawn(
          "z3",
          ["-in"],
          in: :receive,
          out: {:send, self()}
        )
    }

    result = action.(ref)
    Porcelain.Process.stop(ref.proc)
    result
  end
end

defimpl Smt.Interpreter, for: Smt.Interpreter.PorcelainZ3 do
  @spec offer(
          Smt.Interpreter.t(),
          Smt.Instruction.t()
        ) :: Result.t(nil, any())
  def offer(ref, instruction) do
    Porcelain.Process.send_input(
      ref.proc,
      Smt.Render.render(instruction) <> "\n"
    )

    {:ok, nil}
  end

  @spec take(Smt.Interpreter.t()) :: Result.t(String.t(), any())
  def take(ref) do
    pid = ref.proc.pid

    receive do
      {^pid, :data, :out, data} -> {:ok, data}
      {^pid, :data, :error, e} -> {:error, e}
    end
  end
end
