defmodule BlockChain.Transaction do
    defstruct [:sender, :recipient, :amount]

    alias BlockChain.Transaction
    alias BlockChain.Chain
    alias BlockChain.Block
    alias BlockChain.Crypto
    alias BlockChain.User

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

    def insert(tran, id) do
        :ets.insert(String.to_atom("chain" <> id), {:tran, [tran | getTran(id)]})
    end

    def reset(id) do
        # GenServer.call(Tran, :reset)
        :ets.insert(String.to_atom("chain" <> id),{:tran,[]})
    end

    def confirm(data,id) do
        tran = getTran(id)
        IO.inspect data -- tran
        if data -- tran == [] do
            :ets.insert(String.to_atom("chain" <> id),{:tran,tran -- data})
        else
            false
        end
    end

    def creatTran(id) do
        user = User.getUsers()
        if user != [] do
            getTran(hd user)
        else
            []
        end
    end


end