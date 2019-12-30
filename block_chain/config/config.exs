# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :block_chain,
  ecto_repos: [BlockChain.Repo]

# Configures the endpoint
config :block_chain, BlockChainWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tpld0mAFQeAz3yAeeYwSBQwFmnq+p5yMfLQ+G2FkIipUUrwoBl4wLOAuOOKBgmJm",
  render_errors: [view: BlockChainWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BlockChain.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
