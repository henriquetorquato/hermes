defmodule User do
  use Agent

  def start(address, username, room) do
    {node, server} = User.Supervisor.start(address, username)
    {:ok, pid} = Agent.start_link fn -> {node, server, username, room} end

    join_room(node, server, username, room)
    IO.puts "> Client '#{username}' started"
    pid
  end

  def receive_message(originator, content) do
    IO.puts "#{originator}> #{content}"
  end

  def receive_info(info) do
    IO.puts "[info] #{info}"
  end

  def send_message(pid, message) do
    {_, server, user, room} = Agent.get pid, fn state -> state end
    User.Supervisor.spawn_server_task server, :message, [room, user, message]
  end

  defp join_room(node, server, username, room) do
    User.Supervisor.spawn_server_task server, :join, [room, node, username]
  end

end
