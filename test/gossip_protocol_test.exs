defmodule Gossip_ProtocolTest do
  use ExUnit.Case
  doctest Gossip_Protocol

  test "greets the world" do
    assert Gossip_Protocol.hello() == :world
  end
end
