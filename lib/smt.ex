defmodule Smt do
  import Result

  @spec declare(
          Smt.Interpreter.t(),
          String.t()
        ) :: Result.t(nil, any())
  def declare(interpreter, name) do
    Smt.Interpreter.offer(interpreter, {:declare, name})
  end

  @spec assert(
          Smt.Interpreter.t(),
          Smt.Formula.t()
        ) :: Result.t(nil, any())
  def assert(interpreter, formula) do
    Smt.Interpreter.offer(interpreter, {:assert, formula})
  end

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

  @spec get_model(Smt.Interpreter.t()) :: Result.t(String.t(), any())
  def get_model(interpreter) do
    # TODO improve parsing
    Smt.Interpreter.offer(interpreter, {:get_model})
    ~> then(Smt.Interpreter.take(interpreter))
  end
end
