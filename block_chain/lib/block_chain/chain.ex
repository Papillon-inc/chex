defmodule BlockChain.Chain do

  alias BlockChain.Block
  alias BlockChain.Crypto
  alias BlockChain.Transaction
  alias BlockChain.User

  def getChain(id) do
    # GenServer.call(__MODULE__, :get)
    block = :ets.lookup(String.to_atom("chain" <> id), :block)
    block[:block]
  end

    @doc "Create a new blockchain with a zero block"
  def new(id) do
    chain = creatChain(id)
    tran = Transaction.creatTran(id)
    :ets.new(String.to_atom("chain" <> id),[:set, :protected, :named_table])
    :ets.insert(String.to_atom("chain" <> id), [block: (hd chain), tran: tran ])
    User.setUser(id)
    Enum.at(chain,1)
  end

  @doc "Insert given data as a new block in the blockchain"
  def insert(blockchain, data, id) when is_list(blockchain) do
    %{hash: prev, index: index} = hd blockchain

    block =
    data
    |> Block.new(prev, index)
    |> Crypto.put_hash
    |> Map.from_struct
    Transaction.reset(id)
  
    :ets.insert(String.to_atom("chain" <> id), {:block, [block | blockchain]})
    getChain(id)
    # setChain(block)

  end

  def insert(chain ,id) do
    :ets.insert(String.to_atom("chain" <> id), {:block, [chain | getChain(id)]})
    getChain(id)
  end
  
  
  @doc "Validate the complete blockchain"
  def valid?(blockchain) when is_list(blockchain) do
    zero = Enum.reduce_while(blockchain, nil, fn prev, current ->
      cond do
      current == nil ->
        {:cont, prev}
  
      Block.valid?(current, prev) ->
        {:cont, prev}
  
      true ->
        {:halt, false}
    end
    end)
  
  if zero, do: Block.valid?(zero), else: false
  end

  def valid?(chain, id) do
    prev_hash = hd getChain(id)
    prev_hash.hash == chain.prev_hash
  end

  def creatChain(id) do
    
    errorUser = User.getUsers() |> Enum.reduce_while([nil,[],true], fn user, acc ->
      try do
        chain = user |> getChain
        c = hd chain
        ac = hd acc
        # if !ac or ( c.hash == (hd ac).hash and c.index == (hd ac).index ) do
        cond do
        !ac ->
          if chain |> Enum.map(fn(x) -> Map.put(x, :__struct__, Block) end) |> valid? do
            {:cont, [chain, Enum.at(acc,1), Enum.at(acc,2)]}
          else
            User.deleteUser(user)
            {:cont, [(hd acc) , Enum.at(acc,1), false]}
          end
        ac == chain ->
          {:cont, [(hd acc) , Enum.at(acc,1), Enum.at(acc,2)]}
        # else
          # {:cont, [(hd acc), [user | Enum.at(acc, 1)], Enum.at(acc, 2)]}
        true ->
          if chain |> Enum.map(fn(x) -> Map.put(x, :__struct__, Block) end) |> valid? do
            {:cont, [(hd acc), [user | Enum.at(acc, 1)], Enum.at(acc, 2)]}
          else
            User.deleteUser(user)
            {:cont, [(hd acc) , Enum.at(acc,1), false]}
          end
        end
        
      rescue
        e in ArgumentError -> User.deleteUser(user)
        {:cont, acc}
      end
      
    end)
    users = User.getUsers()
    if users != [] do
      if Enum.at(errorUser,1) != [] do
        if div(length(users), 2) < Enum.at(errorUser,1) |> length do
          error = Enum.at(errorUser,1)
          bl = error |> hd |> getChain
          if Enum.all?(tl(error), fn(us) -> bl == getChain(us) end) do
            us = Enum.at(errorUser, 1)
            ch = Enum.at(us, id |> String.to_integer |> rem(length(us)))
            User.setUser(ch)
            [getChain(ch), users -- Enum.at(errorUser,1)]
          else
            eu = vote(Enum.at(errorUser,1))
            us = (users -- Enum.at(errorUser,1))
            if eu |> length > us |> length do
              ch = Enum.at(eu, id |> String.to_integer |> rem(length(eu)))
              [getChain(ch), users -- eu]
            else
              ch = Enum.at(us, id |> String.to_integer |> rem(length(us)))
              [getChain(ch), Enum.at(errorUser,1)]
            end
          end
        else
          # ----1----
          us = users -- Enum.at(errorUser, 1)
          ch = Enum.at(us, id |> String.to_integer |> rem(length(us)))
          User.setUser(ch)
          [getChain(ch), Enum.at(errorUser,1)]
        end
      else
        # -----1------
        us = users -- Enum.at(errorUser, 1)
        ch = Enum.at(us, id |> String.to_integer |> rem(length(us)))
        User.setUser(ch)
        [getChain(ch), Enum.at(errorUser,1)]
      end

    else
      block = Crypto.put_hash(Block.zero)
      |> Map.from_struct
      [[block],Enum.at(errorUser,1)]
    end
  end

  def confirm(chain, id) do
    block = getChain(id) |> hd
    chain.index > block.index and Transaction.confirm(chain.data, id) and valid?(chain, id)
    |> if do
      insert chain, id
    end
  end

  def vote(usrs) do
    vot = usrs
    |>Enum.reduce_while([], fn user, acc ->

      try do
        chain = getChain(user)
        
        block = Enum.reduce_while(acc, nil, fn blockchain, _ch ->
          if (hd blockchain) == chain do
            {:halt, blockchain}
          else
            {:cont, nil}
          end
        end)
        if  block do
          newAcc = acc -- [block]
          users = Enum.at block,1
          {:cont, [[chain,[user | users]] | newAcc]}
        else
          if chain |> Enum.map(fn(x) -> Map.put(x, :__struct__, Block) end) |> valid? do
            {:cont, [[chain, [user]] | acc]}
          else
            User.deleteUser(user)
            {:cont, acc}
          end
        end

        

      rescue
        e in ArgumentError -> User.deleteUser(user)
        {:cont, acc}
      end

    end)
    if length(vot) == 1 do
      vot
      |> hd
      |> Enum.at 1
    else
      v = Enum.reduce_while(vot, [], fn i,max ->
        inte = Enum.at(i,1)
        |> length
        i_max = max
        |> length
        
        
        if(inte > i_max) do
          {:cont, Enum.at(i,1)}
        else
          {:cont, max}
        end
      end)
    end
  end

  def errorNew(id) do
    chain = creatChain(id)
    tran = Transaction.creatTran(id)
    :ets.insert(String.to_atom("chain" <> id), [block: (hd chain), tran: tran ])
  end
end