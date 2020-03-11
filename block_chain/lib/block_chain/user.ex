defmodule BlockChain.User do
    use GenServer

    def init(state), do: {:ok, state}

    def start_link(state \\ []) do
        GenServer.start_link(__MODULE__ ,state, name: User)
        GenServer.start_link(__MODULE__ ,state, name: ErrorUser)
    end

    def handle_call(:get, _from, state), do: {:reply, state, state}

    def handle_cast({:set, user}, state) do
        st = state -- [user]
        {:noreply, [user | st]}
    end

    def handle_cast({:delete, user}, state), do: {:noreply, state --[user]}

    def handle_cast({:setError, users}, state), do: {:noreply, users}

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

    def getError(), do: GenServer.call(ErrorUser, :get)

    def deleteError(user), do: GenServer.cast(ErrorUser, {:delete, user})
end

BlockChain.User.start_link()