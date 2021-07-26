defmodule SSHKeygen.Options do
  alias SSHKeygen.Option

  @know_options %{
    type: %Option{name: "-t", require_arg: true},
    bits: %Option{name: "-b", require_arg: true},
    comment: %Option{name: "-C", require_arg: true},
    new_passphrase: %Option{name: "-N", require_arg: true},
    file: %Option{name: "-f", require_arg: true}
  }

  require SSHKeygen.Options.Helpers
  SSHKeygen.Options.Helpers.option_functions(@know_options)
end
