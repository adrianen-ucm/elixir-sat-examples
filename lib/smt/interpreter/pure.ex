defmodule Smt.Interpreter.Pure do
  @behaviour Smt.Interpreter.Instance
  @type t() :: %__MODULE__{pid: pid()}
  defstruct [:pid]

  @impl Smt.Interpreter.Instance
  @spec with_ref(nil, (t() -> any())) :: any()
  def with_ref(_ \\ nil, action) do
    own_pid = self()
    pid = spawn(fn -> loop(own_pid) end)

    action.(%__MODULE__{
      pid: pid
    })

    send(pid, :close)

    receive do
      {^pid, r} -> r
    end
  end

  # TODO imitate errors from z3 (e.g. variable already
  # defined and variable not defined)
  defp loop(pid, instructions \\ []) do
    receive do
      {:instruction, instruction} ->
        send(
          pid,
          {self(), {:ok, nil}}
        )

        loop(
          pid,
          [instruction | instructions]
        )

      :close ->
        send(
          pid,
          {self(), {:ok, Enum.reverse(instructions)}}
        )

      _ ->
        loop(
          pid,
          [instructions]
        )
    end
  end
end

defimpl Smt.Interpreter, for: Smt.Interpreter.Pure do
  @spec offer(
          Smt.Interpreter.t(),
          Smt.Instruction.t()
        ) :: Result.t(nil, any())
  def offer(ref, instruction) do
    pid = ref.pid
    send(pid, {:instruction, instruction})

    receive do
      {^pid, r} -> r
    end
  end

  @spec take(Smt.Interpreter.t()) :: Result.t(String.t(), any())
  def take(_ref) do
    # TODO simulate response
    {:ok, "sat"}
  end
end
