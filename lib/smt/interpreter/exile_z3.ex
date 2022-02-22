defmodule Smt.Interpreter.ExileZ3 do
  @behaviour Smt.Interpreter.Instance
  @type t() :: %__MODULE__{
          pid_consumer: pid(),
          pid_producer: pid()
        }
  defstruct [:pid_consumer, :pid_producer]

  @impl Smt.Interpreter.Instance
  @spec with_ref(nil, (t() -> any())) :: any()
  def with_ref(_ \\ nil, action) do
    own_pid = self()

    ref = %__MODULE__{
      pid_consumer:
        spawn(fn ->
          consumer(own_pid)
        end),
      pid_producer:
        receive do
          {:pid_producer, pid} -> pid
        end
    }

    result = action.(ref)
    send(ref.pid_producer, :close)
    result
  end

  defp consumer(own_pid) do
    Exile.stream!(~w(z3 -in), input: &producer(own_pid, &1))
    |> Stream.each(&send(own_pid, {self(), {:ok, &1}}))
    |> Stream.run()
  end

  defp producer(own_pid, sink) do
    send(own_pid, {:pid_producer, self()})

    producer_stream()
    |> Enum.into(sink, &(Smt.Render.render(&1) <> "\n"))
  end

  defp producer_stream do
    Stream.transform(Stream.cycle([nil]), nil, fn nil, nil ->
      receive do
        :close ->
          {:halt, nil}

        {:instruction, instruction} ->
          {[instruction], nil}

        _ ->
          {[], nil}
      end
    end)
  end
end

defimpl Smt.Interpreter, for: Smt.Interpreter.ExileZ3 do
  @spec offer(
          Smt.Interpreter.t(),
          Smt.Instruction.t()
        ) :: Result.t(nil, any())
  def offer(ref, instruction) do
    send(ref.pid_producer, {:instruction, instruction})
    {:ok, nil}
  end

  @spec take(Smt.Interpreter.t()) :: Result.t(String.t(), any())
  def take(ref) do
    pid = ref.pid_consumer

    receive do
      {^pid, result} -> result
    end
  end
end
