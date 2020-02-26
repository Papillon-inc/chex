defmodule BlockChainWeb.ChainChannel do
    use Phoenix.Channel
    alias BlockChain.Chain
    alias BlockChain.Transaction
    alias BlockChain.User


    def join("chain:new", msg, socket) do
        {:ok, socket}
    end

    def handle_in("new",params,socket) do
        ch = Chain.new(params["id"])
        if ch != [] do
            broadcast_from!(socket, "errorChain", %{error: ch})
        end
        push(socket,"new", %{chain: Chain.getChain(params["id"])})
        {:noreply, socket}
    end

    def handle_in("get",params,socket) do
        push(socket,"get", %{chain: Chain.getChain(params["id"]), tran: Transaction.getTran(params["id"])})
        {:noreply, socket}
    end

    def handle_in("push",params,socket) do
        broadcast_from!(socket, "newTran", %{id: params["id"]})
        push(socket,"tran", %{transaction: Transaction.insert(params["sender"], params["recipient"], params["amount"], params["id"])})
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
        {:noreply, socket}
    end

    def handle_in("newChain", params, socket) do
        ########################
        Chain.getChain(params["chain_id"])
        |> hd
        |> Chain.confirm(params["id"])
        {:noreply, socket}
    end

    def handle_in("newTran", params, socket) do
        Transaction.getTran(params["tran_id"])
        |>hd
        |> Transaction.insert(params["id"])
        {:noreply, socket}
    end

    def handle_in("errorUser", params, socket) do
        Chain.errorNew(params["id"], params["error"])
        {:noreply, socket}
    end

    intercept ["newChain","newTran","errorChain"]
    def handle_out("newChain", params, socket) do
        push(socket, "inform", %{mode: "0", id: params.id})
        {:noreply, socket}
    end

    def handle_out("newTran", params, socket) do
        push(socket, "inform", %{mode: "1", id: params.id})
        {:noreply, socket}
    end

    def handle_out("errorChain", params, socket) do
        push(socket, "inform", %{error: params.error, mode: "2"})
        {:noreply, socket}
    end



    # ----------error_test---------------
    
    def handle_in("e_new", params, socket) do
        id = params["id"]
        block = BlockChain.Crypto.put_hash(BlockChain.Block.zero)
        |> Map.from_struct
        :ets.new(String.to_atom("chain" <> id),[:set, :protected, :named_table])
        :ets.insert(String.to_atom("chain" <> id), [block: [block], tran: [] ])
        User.setUser(id)
        push(socket, "get", %{chain: Chain.getChain(params["id"]), tran: Transaction.getTran(params["id"])})
        {:noreply, socket}
    end

    def handle_in("setUser", params, socket) do
        id = params["id"]
        User.setUser(id)
        push(socket, "user", %{user: User.getUsers})
        {:noreply, socket}
    end

end