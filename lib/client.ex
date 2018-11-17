#---
# Title        : Assignment - 2,
# Subject      : Distributed And Operating Systems Principles
# Team Members : Priyam Saikia, Noopur R K
# File name    : client.ex
#---

defmodule Client do
  @moduledoc """
  This module acts as the client and sends messages to the server to peform gossip and
  push sum algorithm 
  """
    use GenServer

    def start_link(x) do
        GenServer.start_link(Server, x)
    end

    # -------------------------   Send message for Gossip Algorithm   -------------------------
    def send_message(server) do
        GenServer.cast(server, {:send_message})
    end
    # ------------------------   Send message for Push-sum Algorithm   ------------------------
    def send_message_push_sum(server) do
        GenServer.cast(server, {:send_message_push_sum})
    end

    # ----------------------------------   Setting neighbors  ---------------------------------
    def set_neighbors(server, neighbors) do
        GenServer.cast(server, {:set_neighbors, neighbors})
    end
    # --------------   Keep count of number of times message has been passed   ----------------
    def get_count(server) do
        {:ok, count} = GenServer.call(server, {:get_count, "count"})
        count
    end

    def get_rumour(server) do
        {:ok, rumour} = GenServer.call(server, {:get_rumour, "rumour"})
        rumour
    end

    def has_neighbors(server) do
        {:ok, neighbors} = GenServer.call(server, {:get_neighbors})
        length(neighbors) > 0
    end

    def get_neighbors(server) do
        GenServer.call(server, {:get_neighbors})
    end

    def get_diff(server) do
        GenServer.call(server, {:get_diff})
    end
end
