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

    def deleteTran(tran, id) do
        :ets.insert(String.to_atom("chain" <> id), {:tran, getTran(id) -- tran})
    end

    def insert(sender, recipient, amount, id) do 
        point = User.getPoint Chain.getChain(id), sender
        if amount != "" and point - String.to_integer(amount) >= 0 or sender == "-1" do
            tran = %Transaction{
                sender: sender,
                recipient: recipient,
                amount: amount,
            }
            |> Map.from_struct

            :ets.insert(String.to_atom("chain" <> id), {:tran, [tran | getTran(id)]})
            getTran(id)
        else
            false
        end
    end

    def insert(tran, id) do
        :ets.insert(String.to_atom("chain" <> id), {:tran, [tran | getTran(id)]})
    end

    # def delete(id, data) do
    #     trans = getTran id
    #     :ets.insert(String.to_atom("chain" <> id),{:tran,trans -- data})
    # end

    def confirm(data,id) do
        tran = getTran(id)
        IO.inspect data -- tran
        if data -- tran == [] do
            true
        else
            false
        end
    end

    def point(chain, id) do
        trans = getTran id
        errorTran = Enum.reverse trans
        |> Enum.reduce(%{}, fn tran, acc -> 
            %{sender: sender, amount: amount} = tran
            if sender != "-1" do
                p = Map.get(acc, sender, false)
                if p do
                    points = p - String.to_integer(amount)
                    IO.inspect points < 0
                    if points < 0 do
                        deleteTran [tran], id
                        Map.put(acc, :error, [tran | Map.get(acc, :error, [])])
                    else
                        Map.put(acc, sender, points)
                    end
                else
                    points = User.getPoint(chain, sender) - String.to_integer(amount)
                    if points < 0 do
                        deleteTran [tran], id
                        Map.put(acc, :error, [tran | Map.get(acc, :error, [])])
                    else
                        Map.put(acc, sender, points)
                    end
                end
            else
                acc
            end
        end)
        |> Map.get(:error, [])
        IO.inspect errorTran
        %{tran: trans -- errorTran, error: errorTran}
    end

    def creatTran(id) do
        user = User.getUsers()
        if user != [] do
            Enum.at(user, id |> String.to_integer |> rem(length(user))) |> getTran
        else
            []
        end
    end

    def checkError(error, id) do
        Enum.reduce(error, [], fn tran, acc -> 
            %{sender: sender, recipient: rec} = tran
            if(sender == id or rec == id) do
                [tran | acc]
            else
                acc
            end
        end)
    end


end