defmodule BlockChainWeb.PageController do
  use BlockChainWeb, :controller

  def index(conn, _params) do
    # render(conn, "index.html")
    map = Map.from_struct(hd BlockChain.Chain.new())
    json(conn, map)
  end
end
