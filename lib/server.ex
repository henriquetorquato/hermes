defmodule Server do
  use GenServer

  @impl true
  def init(_args) do
    Process.register(self(), :server)
    { :ok, [] }
  end

  @impl true
  def handle_call({:get_room, room}, _from, rooms) do
    room = Enum.find rooms, nil, fn { name, _sender } -> room == name end
    if room == nil do
      room = spawn(Room, :init, [])
      {:reply, room, rooms}
    end
    {:reply, room, rooms}
  end

  @impl true
  def handle_call({:join, username, room}, user, rooms) do
    {_name, sender} = GenServer.call(self(), {:get_room, room})
    send sender, {:join, username, user}
    {:noreply, rooms}
  end

end
