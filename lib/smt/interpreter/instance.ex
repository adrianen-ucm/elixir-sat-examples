defmodule Smt.Interpreter.Instance do
  @moduledoc """
  Common behavior for an `Smt.Interpreter` module.
  """

  @doc """
  Perform a computation with a fresh `Smt.Interpreter`.
  """
  @callback with_ref((Smt.Interpreter.t() -> any())) :: any()

  @doc """
  Perform a computation with a fresh `Smt.Interpreter`,
  providing also some configuration that depends on the
  specific instance.
  """
  @callback with_ref(
              any(),
              (Smt.Interpreter.t() -> any())
            ) :: any()
end
