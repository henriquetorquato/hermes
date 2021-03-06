defmodule User do
  use Agent

  def start(username, address, roomname) do
    server = connect address

    state = %User.State{
      name: username,
      room: roomname,
      user: node(),
      server: {:receiver, server}
    }

    spawn(User.Receiver, :start, [])
    Agent.start_link(__MODULE__, :init, [state], [name: __MODULE__])
  end

  def init(state) do
    send state.server, {:join, state.room, state.user, state.name}
    state
  end

  def connect(address) do
    server = String.to_atom "server@#{address}"
    case Node.connect server do
      :true ->
        IO.puts "> User connected to '#{server}'"
        server
      :false ->
        IO.puts "> Failed to connect to '#{server}'"
        exit -1
    end
  end

  def message(message) do
    state = Agent.get __MODULE__, fn state -> state end
    send state.server, {:message, %Message{
      originator: state.name,
      recipient: state.room,
      content: message,
      type: "message"
    }}
    :ok
  end

  def receive(message) do
    case message.type do
      "message" -> receive_message message
      "info" -> receive_info message
    end
  end

  def receive_message(message) do
    IO.puts "#{message.originator}> #{message.content}"
  end

  def receive_info(info) do
    IO.puts "[INFO] #{info.content}"
  end

end
