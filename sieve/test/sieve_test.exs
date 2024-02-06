defmodule SieveTest do
  use ExUnit.Case
  doctest Sieve

  test "test max capacity" do
    sieve = (Sieve.new(3,2) |>  Sieve.insert(5,1) |> Sieve.insert(6,2) |> Sieve.insert(7,3))
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {7,3,0}, {6,2,0}, {5,1,0} ]
    assert List.foldl([ {7,3,0}, {6,2,0}, {5,1,0} ], true, fn (x,acc) ->
      {k,v,_} = x
      (sieve |> Sieve.get(k) == v) && acc end) == true
    assert List.foldl([ {7,3,0}, {6,2,0}, {5,1,0} ], true, fn (x,acc) ->
      {k,_,_} = x
      (sieve |> Sieve.get(k) == true) && acc end) == true
    assert sieve.hand == -1
    assert sieve.size == 3
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

  test "eviction function" do
    sieve = (Sieve.new(3,2) |>  Sieve.insert(5,1) |> Sieve.insert(6,2) |> Sieve.insert(7,3) |> Sieve.insert(8,3))
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {8,3,0}, {7,3,0}, {6,2,0} ]
    assert List.foldl([ {8,3,0}, {7,3,0}, {6,2,0} ], true, fn (x,acc) ->
      {k,v,_} = x
      (sieve |> Sieve.get(k) == v) && acc end) == true
    assert sieve.hand == 6
    assert sieve.size == 3
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

  test "insert same value (k + 1) times" do
    sieve = (Sieve.new(3,2) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(5,1))
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {5,1,2} ]
    assert List.foldl([ {5,1,2} ], true, fn (x,acc) ->
      {k,v,_} = x
    (sieve |> Sieve.get(k) == v) && acc end) == true
    assert sieve.hand == -1
    assert sieve.size == 1
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

  test "visited > 0" do
    sieve = (Sieve.new(3,2) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(8,1) |> Sieve.insert(8,1) |> Sieve.insert(3,2))
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {3,2,0}, {8,1,1}, {5,1,2} ]
    assert List.foldl([ {3,2,0}, {8,1,1}, {5,1,2} ], true, fn (x,acc) ->
      {k,v,_} = x
      (sieve |> Sieve.get(k) == v) && acc end) == true
    assert sieve.size == 3
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

  test "hand moves to tail" do
    sieve = (Sieve.new(3,2) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(8,1) |> Sieve.insert(8,1) |> Sieve.insert(3,2) |> Sieve.insert(7,3))
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {7,3,0}, {8,1,0}, {5,1,1} ]
    assert List.foldl([ {7,3,0}, {8,1,0}, {5,1,1} ], true, fn (x,acc) ->
      {k,v,_} = x
      (sieve |> Sieve.get(k) == v) && acc end) == true
    assert sieve.hand == -1
    assert sieve.size == 3
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

  test "same value update" do
    sieve = (Sieve.new(3,2) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(5,3) )
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {5,3,2} ]
    assert List.foldl([ {5,3,2} ], true, fn (x,acc) ->
      {k,v,_} = x
      (sieve |> Sieve.get(k) == v) && acc end) == true
    assert sieve.hand == -1
    assert sieve.size == 1
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

  test "different capacity" do
    sieve = (Sieve.new(5,2) |> Sieve.insert(5,1) |> Sieve.insert(1,1) |> Sieve.insert(2,3) |> Sieve.insert(8,3) |> Sieve.insert(7,1))
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {7,1,0}, {8,3,0}, {2,3,0}, {1,1,0}, {5,1,0} ]
    assert List.foldl([ {7,1,0}, {8,3,0}, {2,3,0}, {1,1,0}, {5,1,0} ], true, fn (x,acc) ->
      {k,v,_} = x
      (sieve |> Sieve.get(k) == v) && acc end) == true
    assert sieve.hand == -1
    assert sieve.size == 5
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

  test "evict requiring one pass" do
    sieve = (Sieve.new(5,2) |> Sieve.insert(5,1) |> Sieve.insert(5,1) |> Sieve.insert(1,1) |> Sieve.insert(1,1) |> Sieve.insert(2,3) |> Sieve.insert(2,3) |> Sieve.insert(8,3) |> Sieve.insert(8,3) |> Sieve.insert(7,1) |> Sieve.insert(7,1) |> Sieve.insert(10,1))
    assert Enum.map(sieve.queue, fn node -> {node.key, node.value, node.visited} end) == [ {10,1,0}, {7,1,0}, {8,3,0}, {2,3,0}, {1,1,0} ]
    assert List.foldl([ {10,1,0}, {7,1,0}, {8,3,0}, {2,3,0}, {1,1,0} ], true, fn (x,acc) ->
      {k,v,_} = x
      (sieve |> Sieve.get(k) == v) && acc end) == true
    assert sieve |> Sieve.contains(100) == false
    assert sieve |> Sieve.contains(7) == true
    assert sieve.hand == 1
    assert sieve.size == 5
    assert Map.new(sieve.queue, fn x -> {x.key, x} end) == sieve.cache
  end

end
