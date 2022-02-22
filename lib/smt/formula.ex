defmodule Smt.Formula do
  @type t(var) ::
          true
          | {:const, boolean()}
          | {:var, var}
          | {:!, t(var)}
          | {:->, t(var), t(var)}
          | {:&&, [t(var), ...]}
          | {:||, [t(var), ...]}
end
