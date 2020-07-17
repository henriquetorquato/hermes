defmodule Room do
  use Agent

  def init(_name) do
    Process.flag(:trap_exit, true)
    loop([])
  end

  def loop(users) do
    receive do
      { :join, user, username } ->
        users = [connect_user(username, user) | users]
        broadcast_info(format_join(username), users)
        loop(users)
      { :message, username, content } ->
        broadcast_message(username, content, users)
        loop(users)
    end
  end

  defp connect_user(username, user) do
    Node.connect user
    {username, user}
  end

  defp broadcast_message(originator, content, users) do
    Enum.each not_user(originator, users),
      fn {_recipient, node} -> send_message(node, originator, content)
    end
  end

  defp broadcast_info(info, users) do
    Enum.each users, fn {_username, user} -> send_info user, info end
  end

  defp send_message(recipient, originator, content) do
    Server.Supervisor.spawn_client_task recipient, :receive_message, [originator, content]
  end

  defp send_info(recipient, info) do
    Server.Supervisor.spawn_client_task recipient, :receive_info, [info]
  end

  defp not_user(username, users) do
    Enum.filter users, fn {name, _node} -> username != name end
  end

  defp format_join(username) do
    "User '#{username}' joined!"
  end

end
