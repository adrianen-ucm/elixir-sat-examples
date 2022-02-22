defmodule Smt.Instruction do
  @type t() ::
          {:declare, String.t()}
          | {:assert, Smt.Formula.t()}
          | {:check_sat}
          | {:get_model}
end
