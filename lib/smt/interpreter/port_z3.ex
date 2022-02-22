defmodule Smt.Interpreter.PortZ3 do
  @behaviour Smt.Interpreter.Instance
  @type t() :: %__MODULE__{port: port()}
  defstruct [:port]

  @impl Smt.Interpreter.Instance
  @spec with_ref(nil, (t() -> any())) :: any()
  def with_ref(_ \\ nil, action) do
    ref = %__MODULE__{
      port:
        Port.open(
          {:spawn_executable, System.find_executable("z3")},
          [:binary, :hide, args: ["-in"]]
        )
    }

    result = action.(ref)
    Port.close(ref.port)
    result
  end
end

defimpl Smt.Interpreter, for: Smt.Interpreter.PortZ3 do
  @spec offer(
          Smt.Interpreter.t(),
          Smt.Instruction.t()
        ) :: Result.t(nil, any())
  def offer(ref, instruction) do
    if Port.command(
         ref.port,
         Smt.Render.render(instruction) <> "\n",
         []
       ) do
      {:ok, nil}
    else
      {:error, "Port command failure"}
    end
  end

  @spec take(Smt.Interpreter.t()) :: Result.t(String.t(), any())
  def take(ref) do
    port = ref.port

    receive do
      {^port, {:data, data}} -> {:ok, data}
      {^port, other} -> {:error, other}
    end
  end
end
