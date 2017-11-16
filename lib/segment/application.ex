defmodule Segment.Application do
  use Application

  @api Application.fetch_env!(:segment, :api)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {@api, []}
    ]

    opts = [strategy: :one_for_one, name: Segment.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
