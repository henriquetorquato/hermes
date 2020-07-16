defmodule Server do
  use GenServer

  def start_link(_args) do
    GenServer.start_link Server, [], debug: [:trace]
  end

  def join(room, user, username) do
    GenServer.cast :server, {:join, room, user, username}
    IO.puts "User '#{user}' joined room '#{room}'"
  end

  def message(room, username, message) do
    GenServer.cast :server, {:message, room, username, message}
    IO.puts "User '#{username}' sent message to room '#{room}'"
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

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:message, roomname, username, content}, rooms) do
    room = get_room(roomname, rooms)
    send room, {:message, username, content}

    {:noreply, rooms}
  end

  defp get_or_create_room(name, rooms) do
    room = get_room(name, rooms)
    case room do
      nil ->
        {:ok, room} = Server.Supervisor.create_room name
        {room, [room | rooms]}
      _ -> {room, rooms}
    end
  end

  defp get_room(name, rooms) do
    Enum.find rooms, nil, fn {room, _} -> room == name end
  end

end
