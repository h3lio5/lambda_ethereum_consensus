defmodule LambdaEthereumConsensus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    checkpoint_sync =
      Application.fetch_env!(:lambda_ethereum_consensus, LambdaEthereumConsensus.ForkChoice)[
        :checkpoint_sync
      ]

    children = [
      {LambdaEthereumConsensus.Telemetry, []},
      {LambdaEthereumConsensus.Store.Db, []},
      {LambdaEthereumConsensus.Beacon.BeaconNode, [checkpoint_sync]},
      {LambdaEthereumConsensus.P2P.Metadata, []},
      {BeaconApi.Endpoint, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LambdaEthereumConsensus.Supervisor]

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeaconApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
