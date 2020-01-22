defmodule BlockChain.User do
    use GenServer

    def init(state), do: {:ok, state}

    def start_link(state \\ []) do
        GenServer.start_link(__MODULE__ ,state, name: User)
    end

    def handle_call(:get, _from, state), do: {:reply, state, state}

    def handle_cast({:set, user}, state) do
        st = state -- [user]
        {:noreply, [user | st]}
    end

    def handle_cast({:delete, user}, state), do: {:noreply, state --[user]}

    def setUser(user) do
        GenServer.cast(User, {:set, user})
    end

    def getUser() do
        GenServer.call(User, :get)
    end

    def deleteUser(user) do
        GenServer.cast(User, {:delete, user})
    end
end

BlockChain.User.start_link()