defmodule User.Receiver do
  use Agent

  def start do
    Agent.start_link __MODULE__, :receiver, [], [name: :receiver, debug: [:trace]]
  end

  def receiver do
    receive do
      {:message, message} ->
        User.receive message
      # {:info, info} ->
      #   User.receive_info info
    end
    receiver()
  end

end
