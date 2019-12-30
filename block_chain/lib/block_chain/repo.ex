defmodule BlockChain.Repo do
  use Ecto.Repo,
    otp_app: :block_chain,
    adapter: Ecto.Adapters.Postgres
end
