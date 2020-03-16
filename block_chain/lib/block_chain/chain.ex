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
  def insert(blockchain, tran, id) when is_list(blockchain) do
    %{hash: prev, index: index} = hd blockchain
    data = tran.tran

    block =
    data
    |> Block.new(prev, index)
    |> Crypto.put_hash
    |> Map.from_struct
    Transaction.deleteTran(data, id)
  
    :ets.insert(String.to_atom("chain" <> id), {:block, [block | blockchain]})
    User.setChain(id)
    User.setErrorChain tran.error
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
    if(User.getChain == []) do
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
          [getChain(ch), Enum.at(errorUser,1)]
        end
      else
        # -----1------
        us = users -- Enum.at(errorUser, 1)
        ch = Enum.at(us, id |> String.to_integer |> rem(length(us)))
        [getChain(ch), Enum.at(errorUser,1)]
      end

    else
      block = Crypto.put_hash(Block.zero)
      |> Map.from_struct
      [[block],Enum.at(errorUser,1)]
    end

    else
      chainUser = User.getChain
      errorUser = User.getError
      if(chainUser |> length >= errorUser |> length) do
        ch = randomGet chainUser, id
        if ch do
          chain = getChain ch
          User.setChain(id)
          [chain,[]]
        else
          User.resetChain
          creatChain id
        end
        
      else
        err = randomGet errorUser, id
        if err do
          error = getChain err
          User.setError(id)
          [error, []]
        else
          User.setError []
          creatChain id
        end
      end
    end
  end

  def randomGet(users, id) do
    user = users
    Enum.reduce_while(users, false, fn x, acc-> 
      ch = Enum.at(user, id |> String.to_integer |> rem(length(user)))
      try do
        getChain ch
        {:halt, ch}
      rescue
        e in ArgumentError -> User.deleteUser(ch)
        user -- [ch]
        {:cont, acc}
      end
    end)
  end

  def confirm(id) do
    ch = User.getChain
    chain = Enum.at(ch, id |> String.to_integer |> rem(length(ch))) |> getChain |> hd
    block = getChain(id) |> hd
    if chain.index > block.index and Transaction.confirm(chain.data, id) and valid?(chain, id) do
      User.setChain id
      
      if User.getErrorChain != [] do
        User.getErrorChain ++ chain.data
      else
        chain.data
      end
      |> Transaction.deleteTran id
      insert chain, id
    else
      User.addError id
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

  def check(id) do
    chain = User.getChain
    error = User.getError
    if chain |> length >= error |> length do
      Enum.any?(error, fn x -> x == id end)
      |> if do
        ch = randomGet chain, id
        if ch do
          :ets.insert(String.to_atom("chain" <> id), [block: getChain(ch), tran: Transaction.getTran(ch)])
          true
        else
          errorNew id
          false
        end
      else
        true
      end
    else
      Enum.any?(chain, fn x -> x == id end)
      |> if do
        ch = randomGet error, id
        if ch do
          :ets.insert(String.to_atom("chain" <> id), [block: getChain(ch), tran: Transaction.getTran(ch)])
        else
          errorNew id
        end
      end
      false
    end
  end
end