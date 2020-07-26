defmodule Hermes do

  def main(args) do
    options = get_options(args)
    case options[:type] do
      "client" -> start_client(
        options[:address],
        options[:username],
        options[:roomname]
      )
      "server" -> start_server(
        options[:address]
      )
      _ ->
        IO.puts "Invalid value for option `type`"
        exit -1
    end
  end

  def parse_options do
    [
      aliases: [
        t: :type,
        a: :address,
        u: :username,
        r: :roomname
      ],
      strict: [
        type:      :string,
        address:   :string,
        username: :string,
        roomname:  :string
      ]
    ]
  end

  def get_options(args) do
    case OptionParser.parse(args, parse_options()) do
      {[], [], _} ->
        IO.puts "Unable to parse options"
        exit -1
      {parsed, _, _} ->
        parsed
    end
  end

  def start_client(address, username, roomname) do
    Agent.start_link Client, :init, [address, username, roomname]
  end

  def start_server(address) do
    GenServer.start_link Server, [address], [name: :server, debug: [:trace]]
  end

end
