defmodule BlockChain.Transaction do
    defstruct [:sender, :recipient, :amount]

    alias BlockChain.Transaction
    alias BlockChain.Chain
    alias BlockChain.Block
    alias BlockChain.Crypto

    # def init(state) do
    #     {:ok, state}
    # end

    # def start_link(state \\ []) do
    #     GenServer.start(__MODULE__, state, name: Tran)
    # end

    # def handle_call({:set, data}, _from, state) do
    #     {:reply, [data | state], [data | state]}
    # end

    # def handle_call(:reset, _from, state) do
    #     {:reply, state, []}
    # end

    def getTran(id) do
        :ets.lookup(String.to_atom("chain" <> id), :tran)[:tran]
    end

    def insert(sender, recipient, amount, id)  do
        tran = %Transaction{
            sender: sender,
            recipient: recipient,
            amount: amount,
        }
        |> Map.from_struct

        
        :ets.insert(String.to_atom("chain" <> id), {:tran, [tran | getTran(id)]})
        getTran(id)
    end

    # def insert(sender, recipient, amount, id) do
    #     tran = %Transaction{
    #         sender: sender,
    #         recipient: recipient,
    #         amount: amount,
    #     }

    #     :ets.insert(String.to_atom("chain" <> id), {:tran, [tran]})
    #     getTran[id]
    # end

    def reset(id) do
        # GenServer.call(Tran, :reset)
        :ets.insert(String.to_atom("chain" <> id),{:tran,[]})
    end


end