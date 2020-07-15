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
            User.setError(ch)
            broadcast_from!(socket, "errorChain", %{})
            spawn(BlockChainWeb.ChainChannel, :deleteError,[])
        end
        # push(socket,"new", %{})
        {:noreply, socket}
    end

    def deleteError() do
        :timer.sleep(60000)
        User.setError([])
    end

    def handle_in("get",params,socket) do
        push(socket,"get", %{chain: Chain.getChain(params["id"]), tran: Transaction.getTran(params["id"])})
        {:noreply, socket}
    end

    def handle_in("push",params,socket) do
        tran = Transaction.insert(params["sender"], params["recipient"], params["amount"], params["id"])
        if tran do
            broadcast_from!(socket, "newTran", %{id: params["id"]})
            # push(socket,"tran", %{})
        end
        {:noreply, socket}
    end

    def handle_in("chain", params, socket) do
        id = params["id"]
        if(User.getChain == []) do
            if(User.getError == []) do
                User.setChain(id)
                chain = Chain.getChain id
                tran = Transaction.point chain, id
                blockchain = Chain.insert(chain, tran, id)
                broadcast_from!(socket, "newChain", %{})
                # push(socket, "chain", %{})
                spawn(BlockChainWeb.ChainChannel, :afterChain, [socket, id])
            else
                spawn(BlockChainWeb.ChainChannel, :oneMinChain, [socket, id])
            end
        else
            Chain.confirm(id)
        end
        {:noreply, socket}
    end

    def oneMinChain(socket, id) do
        if(User.getChain == []) do
        :timer.sleep(60000)
        User.setError([])
        User.setChain(id)
        chain = Chain.getChain id
        tran = Transaction.point chain, id
        blockchain = Chain.insert(chain, tran, id)
        broadcast_from!(socket, "newChain", %{})
        # push(socket, "chain", %{})
        spawn(BlockChainWeb.ChainChannel, :afterChain, [socket, id])
        else
            Chain.confirm(id)
        end
    end

    def afterChain(socket, id) do
        :timer.sleep(6000)
        if(User.getError != [] or User.getChain |> length < User.getUsers |> length or User.getErrorChain != []) do
            broadcast!(socket, "checkChain", %{})
        end
        :timer.sleep(6000)
        User.resetChain
        User.setError([])
        User.setErrorChain []
    end

    def handle_in("checkChain", params, socket) do
        if(User.getError != [] or User.getChain |> length < User.getUsers |> length) do
            if Chain.check params["id"] do
                error = User.getErrorChain
                if error != [] do
                    tran = Transaction.checkError(error, params["id"])
                    if tran != [] do
                        push(socket, "errorTran", %{tran: tran})
                    end
                end
            end
        else
            error = User.getErrorChain
            if error != [] do
                tran = Transaction.checkError(error, params["id"])
                if tran != [] do
                    # push(socket, "errorran", %{tran: tran})
                end
            end
        end
        {:noreply, socket}
    end

    def handle_in("delete", params, socket) do
        id = params["id"]
        User.deleteUser(id)
        {:noreply, socket}
    end

    def handle_in("newChain", params, socket) do
        ########################
        Chain.confirm(params["id"])
        {:noreply, socket}
    end

    def handle_in("newTran", params, socket) do
        Transaction.getTran(params["tran_id"])
        |>hd
        |> Transaction.insert(params["id"])
        {:noreply, socket}
    end

    def handle_in("errorUser", params, socket) do
        id = params["id"]
        error = User.getError
        Enum.any?(error, fn x -> x == id end) or Enum.any?(User.getUsers, fn x -> x == id end)
        |> if do
            Chain.errorNew(id)
            User.deleteError(id)
        end
        {:noreply, socket}
    end

    def handle_in("getPoint", params, socket) do
        id = params["id"]
        push(socket,"point", %{point: User.getPoint(Chain.getChain(id), id)})
        {:noreply, socket}
    end

    intercept ["newChain","newTran","errorChain", "checkChain", "a"]
    def handle_out("newChain", params, socket) do
        push(socket, "inform", %{mode: "0"})
        {:noreply, socket}
    end

    def handle_out("newTran", params, socket) do
        push(socket, "inform", %{mode: "1", id: params.id})
        {:noreply, socket}
    end

    def handle_out("errorChain", params, socket) do
        push(socket, "inform", %{mode: "2"})
        {:noreply, socket}
    end

    def handle_out("checkChain", params, socket) do
        push(socket, "inform", %{mode: "3"})
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
        # push(socket, "get", %{chain: Chain.getChain(params["id"]), tran: Transaction.getTran(params["id"])})
        {:noreply, socket}
    end

    def handle_in("setUser", params, socket) do
        id = params["id"]
        User.setUser(id)
        push(socket, "user", %{user: User.getUsers})
        {:noreply, socket}
    end

    def handle_in("getEC", params, socket) do
        push(socket, "getEC", %{error: User.getError, chain: User.getChain, errorChain: User.getErrorChain})
        {:noreply, socket}
    end

    def handle_in("reset", params, socket) do
        User.resetChain
        User.setError []
        User.setErrorChain []
        {:noreply, socket}
    end

    def handle_in("e_tran", params, socket) do
        tran = Transaction.insert(params["sender"], params["recipient"], params["amount"], params["id"])
        push(socket,"tran", %{transaction: tran})
        {:noreply, socket}
    end

end