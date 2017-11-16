defmodule Segment.Application do
  use Application

  @api Application.get_env(:segment, :api) || Segment.Server

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {@api, []}
    ]

    opts = [strategy: :one_for_one, name: Segment.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
