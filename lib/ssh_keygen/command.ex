defmodule SSHKeygen.Command do
  @moduledoc false
  alias SSHKeygen.Option

  @type options :: [Option.t()]

  @type t :: %__MODULE__{
          options: options
        }

  defstruct options: []
end
