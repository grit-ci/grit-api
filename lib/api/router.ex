defmodule Api.Router do
  use GenServer

  @port 5000
  @dispatch [{:_, [
    # {"/path", Api.Controller.SomeModule, []}
  ]}]

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    :cowboy.start_http(:http, 100,
                       [port: @port],
                       [env: [
                         dispatch: :cowboy_router.compile(@dispatch)
                       ]])
  end
end
