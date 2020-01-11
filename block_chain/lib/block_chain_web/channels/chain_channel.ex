defmodule BlockChainWeb.ChainChannel do
    use Phoenix.Channel
    alias BlockChain.Chain
    alias BlockChain.Transaction


    def join("chain:new", msg, socket) do
        {:ok, socket}
    end

    def handle_in("new",params,socket) do
        # map = Map.from_struct(hd Chain.new(params["id"]))
        push(socket,"new", %{chain: Chain.new(params["id"])})
        {:noreply, socket}
    end

    def handle_in("get",params,socket) do
        # map = Map.from_struct(hd Chain.getChain(params["id"]))
        push(socket,"get", %{chain: Chain.getChain(params["id"])})
        {:noreply, socket}
    end

    def handle_in("push",params,socket) do
        # map = Map.from_struct(hd Transaction.insert(params["sender"], params["recipient"], params["amount"], params["id"]))
        push(socket,"get", %{transaction: Transaction.insert(params["sender"], params["recipient"], params["amount"], params["id"])})
        {:noreply, socket}
    end

    def handle_in("chain", params, socket) do
        id = params["id"]
        chain = Chain.insert(Chain.getChain(id), Transaction.getTran(params["id"]), id)
        push(socket, "chain", %{chain: chain})
        {:noreply, socket}
    end
end