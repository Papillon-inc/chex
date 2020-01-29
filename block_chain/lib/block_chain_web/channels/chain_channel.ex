defmodule BlockChainWeb.ChainChannel do
    use Phoenix.Channel
    alias BlockChain.Chain
    alias BlockChain.Transaction
    alias BlockChain.User


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
        broadcast_from!(socket, "newChain", %{id: id})
        push(socket, "chain", %{chain: chain})
        {:noreply, socket}
    end

    def handle_in("delete", params, socket) do
        id = params["id"]
        User.deleteUser(id)
        IO.puts 123456
        {:noreply, socket}
    end

    def handle_in("newChain", params, socket) do
        ########################
        IO.inspect params["id"]
        hd Chain.getChain(params["chain_id"])
        |> Chain.insert(params["id"])
        {:noreply, socket}
    end

    intercept ["newChain"]
    def handle_out("newChain", params, socket) do
        push(socket, "inform", %{mode: "1", id: params.id})
        {:noreply, socket}
    end
end