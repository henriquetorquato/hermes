defmodule Server do
  use GenServer

  # Server methods

  def start do
    spawn Server.Receiver, :start, []
    DynamicSupervisor.start_link Room.Manager, :start_link, []
    GenServer.start_link __MODULE__, [], name: :server
  end

  def join(roomname, user, username) do
    room = Room.Manager.get_or_create roomname
    Room.join room, user, username
  end

  def message(message) do
    room = Room.Manager.get message[:recipient]
    Room.broadcast room, message
  end

  # GenServer API

  @impl true
  def init(args) do
    IO.puts "> Server started"
    {:ok, args}
  end

end
