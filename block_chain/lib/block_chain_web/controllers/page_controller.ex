defmodule BlockChainWeb.PageController do
  use BlockChainWeb, :controller

  def index(conn, _params) do
    # # render(conn, "index.html")
    # map = Map.from_struct(hd BlockChain.Chain.new())
    pid = :ets.new(:chain, [:set, :private, :named_table])
    t = :ets.insert(:chain, [block: "aaa", c: "bbb"])
    look = :ets.lookup(:chain, :block)
    json(conn, %{body: look[:block]})
  end

  def chain(conn, _params) do
    ch = BlockChain.Chain.getChain("0")
    map = Map.from_struct(hd BlockChain.Chain.insert(ch, "aaa"))
    json(conn, map)
  end

  def block(conn, %{"id" => id}) do
    conn
    |>put_layout(false)
    |>render("index.html", id: id)
  end
end
