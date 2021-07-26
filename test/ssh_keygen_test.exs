defmodule SSHKeygenTest do
  use ExUnit.Case
  doctest SSHKeygen

  test "greets the world" do
    assert SSHKeygen.hello() == :world
  end
end
