defmodule Smt.Instruction do
  @moduledoc """
  SMT-LIB instruction related types and utilities.
  """

  @typedoc """
  A tagged union type for SMT-LIB expressions.
  """
  @type t() ::
          {:declare, String.t()}
          | {:assert, Smt.Formula.t(String.t())}
          | {:check_sat}
          | {:get_model}
end
