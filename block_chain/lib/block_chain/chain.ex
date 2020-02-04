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
    # start_link([chain])
    # Transaction.start_link()
    :ets.new(String.to_atom("chain" <> id),[:set, :protected, :named_table])
    :ets.insert(String.to_atom("chain" <> id), [block: chain, tran: tran ])
    User.setUser(id)
    [chain]
  end

  @doc "Insert given data as a new block in the blockchain"
  def insert(blockchain, data, id) when is_list(blockchain) do
    %{hash: prev, index: index} = hd blockchain

    block =
    data
    |> Block.new(prev, index)
    |> Crypto.put_hash
    |> Map.from_struct
    IO.inspect block
    Transaction.reset(id)
  
    :ets.insert(String.to_atom("chain" <> id), {:block, [block | blockchain]})
    getChain(id)
    # setChain(block)

  end

  def insert(chain ,id) do
    IO.inspect id
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
    
    errorUser = User.getUsers() |> Enum.reduce_while([nil,[]], fn user, acc ->
      try do
        chain = user |> getChain
        if ( (hd chain).hash == (hd acc).hash and (hd chian).index == (hd acc).index ) or !(hd acc)
        if user |> getChain |> Enum.map(fn(x) -> Map.put(x, :__struct__, Block) end) |> valid? do
          {:cont, acc}
        else
          {:cont, [acc | user]}
        end

      rescue
        e in ArgumentError -> User.deleteUser(user)
        {:cont, acc}
      end
      
    end)
    users = User.getUsers()
    if users != [] do
      if errorUser ==[] do
        getChain(hd users)
      end
    else
      block = Crypto.put_hash(Block.zero)
      |> Map.from_struct
      [block]
    end
  end

  def confirm(chain, id) do
    Transaction.confirm(chain.data, id) and valid?(chain, id)
    |> if do
      insert chain, id
    end
  end

  def vote() do
    vot = User.getUsers()
    |>Enum.reduce_while([], fn user, acc ->

      try do
        chain = getChain(user)
        if chain |> Enum.map(fn(x) -> Map.put(x, :__struct__, Block) end) |> valid? do
        
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
            {:cont, [[chain, [user]] | acc]}
          end

        else
          {:cont, acc}
        end

      rescue
        e in ArgumentError -> User.deleteUser(user)
        {:cont, acc}
      end

    end)
    if length(vot) == 1 do
      []
    else
      v = Enum.reduce_while(vot, [0,[]], fn i,max ->
        inte = Enum.at(i,1)
        |> length
        i_max = Enum.at(max,1)
        |> length
        
        
        if(inte > i_max) do
          IO.inspect inte
          {:cont, i}
        else
          {:cont, max}
        end
      end)
      IO.inspect vot -- [v]
      Enum.reduce(vot -- [v], [], fn chain, users ->
        Enum.at(chain,1) ++ users
      end)
    end
    |> IO.inspect
  end
end
