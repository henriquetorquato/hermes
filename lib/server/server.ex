defmodule Server do
  use Supervisor

  def init(_) do
    children = [
      {Room.Manager, []},
      {Server.Receiver, [name: :receiver, debug: [:trace]]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def join(roomname, user, username) do
    room = Room.Manager.get_or_create roomname
    Room.join room, user, username
  end

  def message(message) do
    room = Room.Manager.get message.recipient
    Room.broadcast room, message
  end

end
