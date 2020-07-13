defmodule Hermes do
  use Supervisor

  # variables started with `_` are not ment to use
  def init(_init_args) do
    children = [
      { Server, [] }
    ]

    # `:one_for_one` if a child process terminates, only that process is restarted
    Supervisor.init(children, strategy: :one_for_one)
  end

end
