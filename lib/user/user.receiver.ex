defmodule User.Receiver do
  use Agent

  def start do
    Agent.start_link __MODULE__, :init, [], [name: :receiver, debug: [:trace]]
  end

  def init do
    IO.puts "> User receiver started"
    receiver()
  end

  def receiver do
    receive do
      {:message, message} ->
        User.receive_message message
      {:info, info} ->
        User.receive_info info
    end
    receiver()
  end

end
