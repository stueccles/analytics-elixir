defmodule Segment.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Segment.Worker, []}
    ]

    opts = [strategy: :one_for_one, name: Segment.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
