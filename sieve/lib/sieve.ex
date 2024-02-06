defmodule Sieve do

  defstruct capacity: 0,
    cache: %{},
    queue: [],
    hand: -1,
    k: 1,
    size: 0

  def new(capacity, k) do
    %__MODULE__{capacity: capacity, k: k}
  end

  # update queue, cache, and increments size
  defp add(%Sieve{} = curr, %SieveNode{} = node) do
    %{curr | queue: [node | curr.queue], cache: Map.put(curr.cache, node.key, node), size: curr.size + 1}
  end

  # remove from queue, cache and decrements size
  defp remove(%Sieve{} = curr, %SieveNode{} = node) do
    %{curr | queue: List.delete(curr.queue, node), cache: Map.delete(curr.cache, node.key), size: curr.size - 1 }
  end

  # decrement all values in elements that are in cache
  defp decrement_cache(%Sieve{} = curr, elements) do
    cache = List.foldl(MapSet.to_list(elements), curr.cache, fn (x,updated_cache) -> Map.put(updated_cache, x.key, %{x | visited: max(x.visited - 1, 0)}) end)
    %{curr | cache: cache}
  end

  # decrement all values in elements that are in queue
  defp decrement_queue(%Sieve{} = curr, elements) do
    queue = Enum.map(curr.queue,
    fn x ->
      if MapSet.member?(elements, x) do %{x | visited: max(x.visited - 1, 0)} else x end
    end)
    %{curr | queue: queue}
  end

  # returns the updated sieve with the candidate evicted along with the candidate
  defp evict_candidate(%Sieve{} = curr, hand) do
    {update, _, candidate} = List.foldr(curr.queue, {MapSet.new(), false, nil},
    fn(x, acc) ->
	    {update, inRange, candidate} = acc
	    inRange = if x.key === hand do true else inRange end
	    {update, inRange, candidate} =
      if inRange do
	      if (x.visited === 0) do {update, false, x} else {update |> MapSet.put(x), inRange, candidate} end
	    else
	      {update, inRange, candidate}
	    end
	    {update, inRange, candidate}
    end)

    curr = decrement_queue(%Sieve{} = curr, update) |> decrement_cache(update)
    if candidate === nil do evict_candidate(curr, List.last(curr.queue).key) else {remove(curr, candidate), candidate.key} end
  end

  # finds the index of an element in the queue
  defp find_index(queue, element) do
    List.foldl(queue, {0, false},
    fn(x, acc) ->
	    {l, r} = acc
	    r = if x.key === element do true else r end
	    l = if r === true do l else l + 1 end
	    {l, r}
    end) |> elem(0)
  end

  # finds the element to evict and updates the hand
  defp evict(%Sieve{} = curr) do
    obj = if curr.hand != -1 do curr.hand else List.last(curr.queue).key end
    {new_curr, candidate} = evict_candidate(curr, obj)
    index = find_index(curr.queue, candidate) - 1
    hand = if index >= 0 do (Enum.fetch(new_curr.queue, index) |> elem(1)).key else -1 end
    %{new_curr | hand: hand}
  end

  # increments visited and updates the value stored in the cache
  defp increment_visited_update_value(%Sieve{} = curr, node, value, k) do
    updated_node = %{node | value: value, visited: min(node.visited + 1, k) }
    queue = Enum.map(curr.queue,
    fn x ->
      if x === node do updated_node else x end
    end)

    %{curr | queue: queue, cache: Map.put(curr.cache, node.key, updated_node)}
  end

  # get the value in the cache
  def get(%Sieve{} = curr, key, default \\ nil) do
    Map.get(curr.cache, key, default).value
  end

  # checks if the cache contains the key
  def contains(%Sieve{} = curr, key) do
    Map.has_key?(curr.cache, key)
  end

  # inserts new key value pair into cache
  def insert(%Sieve{} = curr, key, value) do
    if Map.has_key?(curr.cache, key) do
      node = Map.get(curr.cache, key)
      increment_visited_update_value(curr, node, value, curr.k)
    else
      curr = if curr.size === curr.capacity do evict(curr) else curr end
      add(curr, SieveNode.new(key, value))
    end
  end
end
