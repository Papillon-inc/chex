defmodule BlockChain.User do
    use GenServer

    def init(state), do: {:ok, state}

    def start_link(state \\ []) do
        GenServer.start_link(__MODULE__ ,state, name: User)
        GenServer.start_link(__MODULE__ ,state, name: ErrorUser)
        GenServer.start_link(__MODULE__ ,state, name: ChainUser)
        GenServer.start_link(__MODULE__ ,state, name: ErrorChain)
    end

    def handle_call(:get, _from, state), do: {:reply, state, state}

    def handle_cast({:set, user}, state) do
        st = state -- [user]
        {:noreply, [user | st]}
    end

    def handle_cast({:delete, user}, state), do: {:noreply, state --[user]}

    def handle_cast({:setError, users}, state), do: {:noreply, users}

    def handle_cast(:reset, _state), do: {:noreply, []}

    def setUser(user) do
        GenServer.cast(User, {:set, user})
    end

    def getUsers() do
        GenServer.call(User, :get)
    end

    def deleteUser(user) do
        GenServer.cast(User, {:delete, user})
    end

    def getPoint(chain, id) do
        Enum.reduce(chain, 0, fn(block, acc) ->
            if is_list(block.data) do
                Enum.reduce(block.data, 0, fn(tran, ac) -> 
                    cond do
                        is_bitstring(tran) ->
                            0
                        tran.sender == id ->
                            ac - String.to_integer(tran.amount)
                        tran.recipient == id ->
                            ac + String.to_integer(tran.amount)
                        true ->
                            ac
                    end
                end) + acc
            else
                acc
            end
        end)
    end

    def setError(users), do: GenServer.cast(ErrorUser, {:setError, users})

    def addError(user), do: GenServer.cast(ErrorUser, {:set, user})

    def getError(), do: GenServer.call(ErrorUser, :get)

    def deleteError(user), do: GenServer.cast(ErrorUser, {:delete, user})

    def setChain(user), do: GenServer.cast(ChainUser, {:set, user})

    def getChain(), do: GenServer.call(ChainUser, :get)

    def deleteChain(user), do: GenServer.cast(ChainUser, {:delete, user})

    def resetChain(), do: GenServer.cast(ChainUser, :reset)

    def setErrorChain(chain), do: GenServer.cast(ErrorChain, {:setError, chain})

    def getErrorChain(), do: GenServer.call(ErrorChain, :get)

end

BlockChain.User.start_link()