defmodule Server.Receiver do
  use Agent

  def start_link(opts) do
    Agent.start __MODULE__, :receiver, [], opts
  end

  def receiver do
    receive do
      {:message, message} ->
        Server.message message
        IO.inspect "> Received message #{message}"
      {:join, room, node, username} ->
        Server.join room, node, username
        IO.puts "> User '#{username}' joined room '#{room}'"
    end
    receiver()
  end

end
