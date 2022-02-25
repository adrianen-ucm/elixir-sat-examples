defmodule Smt.Formula do
  @moduledoc """
  Formula related types and utilities.
  """

  @typedoc """
  A tagged union type for a formula term.
  """
  @type t(var) ::
          {:const, boolean()}
          | {:var, var}
          | {:!, t(var)}
          | {:->, t(var), t(var)}
          | {:&&, [t(var), ...]}
          | {:||, [t(var), ...]}
end
