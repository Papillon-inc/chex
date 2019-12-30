defmodule BlockChain.Transaction do
    defstruct [:sender, :recipient, :amount]

    use GenServer

    alias BlockChain.Transaction
    alias BlockChain.Chain
    alias BlockChain.Block
    alias BlockChain.Crypto

    def init(state) do
        {:ok, state}
    end

    def start_link(state \\ []) do
        GenServer.start(__MODULE__, state, name: Tran)
    end

    def handle_call({:set, data}, _from, state) do
        {:reply, [data | state], [data | state]}
    end

    def handle_call(:reset, _from, state) do
        {:reply, state, []}
    end

    def new(sender, recipient, amount) do
        tran = %Transaction{
            sender: sender,
            recipient: recipient,
            amount: amount,
        }

        GenServer.call(Tran, {:set, tran})
    end

    def reset() do
        GenServer.call(Tran, :reset)
    end


end