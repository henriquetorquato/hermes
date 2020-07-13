defmodule Server do
  use Agent

  def start do
    spawn(Server, :init, [])
  end

  def init do
    Process.flag(:trap_exit, true)
    loop([])
  end

  def loop(rooms) do
    receive do
      { :join, user, room } ->
        sender = find_room(room, rooms)
        if sender != nil do
          send sender, { :join, user }
          loop(rooms)
        end

        sender = spawn(Room, :init, [[user]])
        loop([{ room, sender } | rooms])

      { :message, room, username, content } ->
        send find_room(room, rooms), { :message, username, content }
        loop(rooms)
    end
  end

  defp find_room(id, [{u, p} | _]) when u == id, do: p
  defp find_room(_, []), do: nil

end
