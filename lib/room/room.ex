defmodule Room do
  use Agent

  def init(_args) do
    {:ok, []}
  end

  def start_link([], name) do
    Agent.start_link __MODULE__, :init, [name], name: String.to_atom name
  end

  def join(room, node, username) do
    Node.connect node
    user = {username, node}

    Agent.get_and_update room, fn users -> [user | users] end
  end

  def broadcast(pid, message) do
    users = get_users pid
    case message[:type] do
      "message" ->
        users = not_user message[:originator], users
        broadcast pid, message, users
      "info" ->
        broadcast pid, message, users
    end
  end

  def broadcast(_pid, message, users) do
    Enum.each users, fn {_username, node} -> send_message node, message end
  end

  defp get_users(pid) do
    Agent.get pid, fn users -> users end
  end

  defp not_user(username, users) do
    Enum.filter users, fn {name, _node} -> username != name end
  end

  defp send_message(node, message) do
    send {:receiver, node}, message
  end

end
