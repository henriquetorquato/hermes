defmodule Server.Receiver do
  use Agent

  def start do
    Agent.start_link __MODULE__, :init, [], [name: :receiver, debug: [:trace]]
  end

  def init do
    IO.puts "> Server receiver started"
    receiver()
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
