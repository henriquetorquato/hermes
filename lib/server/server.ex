defmodule Server do
  use GenServer

  def start_link(_args) do
    GenServer.start_link Server, [], [name: :server, debug: [:trace]]
  end

  def join(room, user, username) do
    GenServer.cast :server, {:join, room, user, username}
  end

  def message(room, username, message) do
    GenServer.cast :server, {:message, room, username, message}
  end

  @impl true
  def init(args) do
    IO.puts "> Server started"
    {:ok, args}
  end

  @impl true
  def handle_cast({:join, roomname, user, username}, rooms) do
    {{_name, room}, new_state} = get_or_create_room(roomname, rooms)
    send room, {:join, user, username}

    IO.puts "> User '#{user}' joined room '#{roomname}'"
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:message, roomname, username, content}, rooms) do
    {_name, room} = get_room(roomname, rooms)
    send room, {:message, username, content}

    IO.puts "> User '#{username}' sent message to room '#{roomname}'"
    {:noreply, rooms}
  end

  defp get_or_create_room(name, rooms) do
    room = get_room(name, rooms)
    case room do
      nil ->
        room = create_room name
        {room, [room | rooms]}
      _ -> {room, rooms}
    end
  end

  defp get_room(name, rooms) do
    Enum.find rooms, nil, fn {room, _} -> room == name end
  end

  defp create_room(name) do
    pid = spawn(Room, :init, [name])
    {name, pid}
  end

end
