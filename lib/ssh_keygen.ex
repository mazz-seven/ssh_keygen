defmodule SSHKeygen do
  @moduledoc """
  Create and execute ssh-keygen CLI commands.
  The API is a builder, building up the list of options.

  ## Example:

  import SSHKeygen
  use SSHKeygen.Options

  command =
    SSHKeygen.new_command
    |> type("rsa")
    |> bits_size(4096)
    |> comment("example@email.com")

    :ok = execute(command)
  """
  alias SSHKeygen.Command
  alias SSHKeygen.Option
  alias Porcelain.{Result, Process}

  @ssh_keygen_path System.find_executable("ssh-keygen")

  @doc """
  Begin a new blank (no options) ssh-keygen command.
  """
  def new_command, do: %Command{}

  @doc """
  Add a option to the command.
  """
  def add_option(%Command{options: options} = command, %Option{} = option) do
    %Command{command | options: [option | options]}
  end

  @doc """
  Execute the command using ssh-keygen CLI.
  Returns `:ok` on success, or `{:error, {cmd_output, exit_status}}` on error.
  """
  @spec execute(command :: Command.t()) ::
          {:ok, output :: any} | {:error, :noproc | :timeout}
  def execute(%Command{} = command) do
    {executable, cmd_args} = prepare(command)

    proce = Porcelain.spawn(executable, cmd_args)

    case Process.await(proce, 1000) do
      {:ok, %Result{out: _output, status: _status}} ->
        {:ok, get_public_key(command)}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Prepares the command to be executed, by converting the `%Command{}` into
  proper parameters to be feeded to `System.cmd/3` or `Port.open/2`.
  Returns `{ffmpeg_executable_path, list_of_args}`.
  """
  @spec prepare(command :: Command.t()) :: {binary() | nil, list(binary)}
  def prepare(%Command{options: options}) do
    options = Enum.map(options, &arg_for_option/1)
    cmd_args = List.flatten(options)
    {@ssh_keygen_path, cmd_args}
  end

  defp arg_for_option(%Option{name: name, require_arg: false, argument: nil}) do
    [name]
  end

  defp arg_for_option(%Option{name: name, argument: arg}) when not is_nil(arg) do
    [name, arg]
  end

  defp get_public_key(command) do
    %Option{argument: file_path} =
      Enum.find(command.options, fn option -> option.name == "-f" end)

    %Result{out: output, status: _status} = Porcelain.shell("cat " <> file_path <> ".pub")
    String.trim(output)
  end
end
