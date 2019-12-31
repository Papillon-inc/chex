defmodule BlockChainWeb.ChainChannel do
    use Phoenix.Channel
    alias BlockChain.Chain
    alias BlockChain.Transaction


    def join("chain:new", msg, socket) do
        {:ok, socket}
    end

    def handle_in("new",params,socket) do
        map = Map.from_struct(hd Chain.new(params["id"]))
        push(socket,"new", map)
        {:noreply, socket}
    end

    def handle_in("get",params,socket) do
        map = Map.from_struct(hd Chain.getChain(params["id"]))
        push(socket,"get", map)
        {:noreply, socket}
    end

    def handle_in("push",params,socket) do
        map = Map.from_struct(hd Transaction.insert(params["sender"], params["recipient"], params["amount"], params["id"]))
        push(socket,"get", map)
        {:noreply, socket}
    end
end