defmodule User.Supervisor do
  use Supervisor

  def init(args) do
    {:ok, args}
  end

  def start(address, username) do
    node = start_node username, address
    server = connect_server address

    children = [
      {Task.Supervisor, name: User.TaskSupervisor}
    ]

    Supervisor.start_link children, [strategy: :one_for_one]
    IO.puts "> User supervisor started"

    {node, server}
  end

  def start_node(username, address) do
    node = String.to_atom "#{username}@#{address}"
    Node.start node
    IO.puts "> Node started as '#{node}'"
    node
  end

  def connect_server(address) do
    node = String.to_atom "server@#{address}"

    case Node.connect node do
      :true ->
        IO.puts "> Connected to server node '#{node}'"
        node
      :false ->
        IO.puts "> Server is unavailable, shutting down client"
        exit :shutdown
    end
  end

  def spawn_server_task(recipient, name, args) do
    {Server.TaskSupervisor, recipient}
    |> Task.Supervisor.async(Server, name, args)
    |> Task.await
  end

end
