#---
# Title        : Assignment - 2,
# Subject      : Distributed And Operating Systems Principles
# Team Members : Priyam Saikia, Noopur R K
# File name    : gossip_algo.ex
#---

defmodule Gossip_Protocol do
  @moduledoc """
  This module validates the topology and alogorithms requested to be implemented and 
  determines the different set of neighbor nodes that needs to be communicated with 
  for various topologies. The requested algorithm is then invoked through a server-client
  module.
  
  Topologies Implemented:
  1. Full Network - full
  2. 3D Grid - 3D
  3. Random 2D Grid - rand2D
  4. Torus - torus
  5. Line - line
  6. Imperfect Line - impLine
  
  Algorithms Implemented:
  1. Gossip - gossip
  2. Push Sum - push-sum
  """
  
  #  ---------------------   Take arguments and validate   ---------------------
  def main(arg1, arg2, arg3) do
  #def main(args \\ []) do
    totNodes = arg1 # Total number of nodes
    if totNodes > 1 do
        topology = arg2 # Topology requested
        algo = arg3 # Algorithm requested

        case algo do
          "gossip" ->
                IO.puts "Running Gossip algorithm"
                actors = init_actors(totNodes)
                init_algorithm(actors, topology, totNodes, algo)

          "push-sum" ->
                IO.puts "Running Push-Sum algorithm"
                actors = init_actors_push_sum(totNodes)
                init_algorithm(actors, topology, totNodes, algo)
           _ ->
             IO.puts "Oops! Invalid algorithm!"
             IO.puts "Worry Not! Use gossip or push-sum only"
             System.halt(0)
        end
    end
    
    #{_, input, _} = OptionParser.parse(args)
    #numNodes = 0
    #
    #if length(input) == 3 do
    #
    #  numNodes = String.to_integer(List.first(input))
    #
    #  if numNodes > 1 do
    #
    #    algorithm = List.last(input)
    #    {topology, _} = List.pop_at(input, 1)
    #
    #    case algorithm do
    #
    #      "gossip" ->
    #            IO.puts "Using Gossip algorithm"
    #            actors = init_actors(numNodes)
    #            init_algorithm(actors, topology, numNodes, algorithm)
    #
    #      "push-sum" ->
    #            IO.puts "Using push-sum algorithm"
    #            actors = init_actors_push_sum(numNodes)
    #            init_algorithm(actors, topology, numNodes, algorithm)
    #       _ ->
    #         IO.puts "Invalid algorithm"
    #         IO.puts "Enter gossip or push-sum"
    #         System.halt(0)
    #    end
    #  end
    #
    #else
    #  IO.puts "Invalid input. Number of arguments should be 3"
    #  IO.puts "Example: ./project2 30 2D gossip"
    #  System.halt(0)
    #end
  end

  #  --------------------   Prepare Actors to start Rumour for gossip protocol   --------------------
  def init_actors(totNodes) do
    midNode = trunc(totNodes/2)

    Enum.map(1..totNodes, fn x -> {:ok, actor} = cond  do
                                      x == midNode ->  Client.start_link("Rumour have started")
                                      true ->  Client.start_link("")
                                   end
                                   actor end)
  end

  #  --------------------   Prepare Actors to start Rumour for Push-sum   --------------------
  def init_actors_push_sum(totNodes) do
    midNode = trunc(totNodes/2)
    Enum.map(1..totNodes,
      fn x -> {:ok, actor} =
        cond do
          x == midNode ->
            x = Integer.to_string(x)
            {x, _} = Float.parse(x)
            Client.start_link([x] ++ ["Rumour have started"])
          true ->
            x = Integer.to_string(x)
            {x, _} = Float.parse(x)
            Client.start_link([x] ++ [""])
        end
      actor
      end)
  end

  #  -------------------------------   Verify topology requested   -------------------------------
  def init_algorithm(actors, topology, totNodes, algo) do

    :ets.new(:count, [:set, :public, :named_table])
    :ets.insert(:count, {"spread", 0})
    
    # Determine Neighbor nodes as per requested topology
    neighbors =
    case topology do
      "full" ->
            IO.puts "Implementing full topology"
            _neighbors = determine_nodes_full(actors)
      "3D" ->
            IO.puts "Implementing 3D topology"
            _neighbors = determine_nodes_3D(actors, topology)
      "imp3D" ->
            IO.puts "Implementing Imperfect 3D topology"
            _neighbors = determine_nodes_3D(actors, topology)
      "2D" ->
            IO.puts "Implementing 2D topology"
            _neighbors = determine_nodes_2D(actors, topology)
      "rand2D" ->
            IO.puts "Implementing random 2D topology"
            _neighbors = determine_nodes_2D(actors, topology)
      "torus" ->
            IO.puts "Implementing torus topology"
            _neigbours = determine_nodes_torus(actors)
      "line" ->
            IO.puts "Implementing line topology"
            _neighbors = determine_nodes_line(actors, topology)
      "impLine" ->
            IO.puts "Implementing Imperfect line topology"
            _neighbors = determine_nodes_line(actors, topology)
       _ ->
            IO.puts "Oops! Invalid topology!"
            IO.puts "Please use one of full/3D/rand2D/torus/line/impLine as topology"
            System.halt(0)
    end

    set_neighbors(neighbors)
    prev = System.monotonic_time(:milliseconds)

    if (algo == "gossip") do
      # call gossip algorithm
      gossip(actors, neighbors, totNodes)
    else
      # call push-sum algorithm
      push_sum(actors, neighbors, totNodes)
    end
    IO.puts "Time to Converge: " <> to_string(System.monotonic_time(:milliseconds) - prev) <> " ms"
    System.halt(0)
  end

  #  -------------------------------   Start Gossip   -------------------------------  
  def gossip(actors, neighbors, totNodes) do
    #for  {magicN, y}  <-  neighbors  do
    for  {magicN, _}  <-  neighbors  do
      Client.send_message(magicN)
    end

    actors = verify_actors_alive(actors)
    [{_, spread}] = :ets.lookup(:count, "spread")

    if ((spread != totNodes) && (length(actors) > 1)) do
      neighbors = Enum.filter(neighbors, fn {magicN,_} -> Enum.member?(actors, magicN) end)
      gossip(actors, neighbors, totNodes)
    end
  end

  def verify_actors_alive(actors) do
    this_actors = Enum.map(actors, fn x -> if (Process.alive?(x) && Client.get_count(x) < 10  && Client.has_neighbors(x)) do x end end)
    List.delete(Enum.uniq(this_actors), nil)
  end

  #  ---------------------   Start Push Sum   ---------------------
  def push_sum(actors, neighbors, totNodes) do
    #for  {magicN, y}  <-  neighbors  do
    for  {magicN, _}  <-  neighbors  do
      Client.send_message_push_sum(magicN)
    end

    actors = verify_actors_alive_ps(actors)
    [{_, spread}] = :ets.lookup(:count, "spread")
    
    if ((spread != totNodes) && (length(actors) > 1)) do
      neighbors = Enum.filter(neighbors, fn ({magicN,_}) -> Enum.member?(actors, magicN) end)
      push_sum(actors, neighbors, totNodes)
    end
  end

  def verify_actors_alive_ps(actors) do
    this_actors = Enum.map(actors,
        fn x ->
          diff = Client.get_diff(x)
          if(Process.alive?(x) && Client.has_neighbors(x) && (abs(List.first(diff)) > :math.pow(10, -10)
                 || abs(List.last(diff)) > :math.pow(10, -10))) do
             x
          end
        end)
    List.delete(Enum.uniq(this_actors), nil)
  end

  #  ---------------------   Determine neighbor nodes for full topology  ---------------------
  def determine_nodes_full(actors) do
    Enum.reduce(actors, %{}, fn (x, acc) ->  Map.put(acc, x, Enum.filter(actors, fn y -> y != x end)) end)
  end
  
  #  ---------------------   Determine neighbor nodes for line topology  ---------------------
  def determine_nodes_line(actors, topology) do
    indexed_actors = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({y,magicN}, acc) -> Map.put(acc, magicN, y) end)
    #first = Enum.at(actors,0)
    #lastIndex = length(actors) - 1
    #last = Enum.at(actors, lastIndex)
    #Enum.reduce(actors, %{}, fn (x, acc) -> {:ok, currentIndex} = Map.fetch(indexed_actors, x)
    #                                        cond do
    #                                          x == first -> Map.put(acc, x, [Enum.at(actors, 1)])
    #                                          x == last -> Map.put(acc, x, [Enum.at(actors, lastIndex - 1)])
    #                                          true -> Map.put(acc, x, [Enum.at(actors, currentIndex - 1), Enum.at(actors, currentIndex + 1)])
    #                                        end end)
    #end
    #def get_line_neighbors(actors, topology) do
    # # actors_with_index = %{pid1 => 0, pid2 => 1, pid3 => 2}
    #actors_with_index = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({v,k}, acc) -> Map.put(acc, k, v) end)
    n = length(actors)
    Enum.reduce(0..n-1, %{}, fn (x, acc) ->
        neighbors =
          cond do
            x == 0 -> [1]
            x == n-1 -> [n - 2]
            true -> [(x - 1), (x + 1)]
          end
          neighbors =
              case topology do
                "impLine" ->
                   neighbors ++ get_random_node(neighbors, x, n-1) 
                _ -> neighbors
              end

          neighbor_pids = Enum.map(neighbors, fn i ->
            {:ok, n} = Map.fetch(indexed_actors, i)
            n end)

         {:ok, actor} = Map.fetch(indexed_actors, x)
         Map.put(acc, actor, neighbor_pids)
        end)
  end
  
  #  ---------------------   Determine neighbor nodes for 3D topology  ---------------------
  def determine_nodes_3D(actors, topology) do
  n = length(actors)
  magicN = trunc(:math.ceil(cbrt(n)))
  indexed_actors = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({y,magicN}, acc) -> Map.put(acc, magicN, y) end)
  
  #final_neighbors = Enum.reduce(0..n-1, %{}, fn i,acc ->
  Enum.reduce(0..n-1, %{}, fn i,acc ->
      level = trunc(:math.floor(i / (magicN * magicN)))
      upperlimit = (level + 1) * magicN * magicN
      lowerlimit = level * magicN * magicN
      neighbors = Enum.reduce(1..6, %{}, fn (j, acc) ->
         # Get 6 neighbors
         if (j == 1) && ((i - magicN) >= lowerlimit) do 
          Map.put(acc, j, (i - magicN))
         else
          if (j == 2) && ((i + magicN) < upperlimit) && ((i+magicN)< n) do
            Map.put(acc, j, (i+magicN))
          else
            if (j == 3) && (rem((i - 1), magicN) != (magicN - 1)) && ((i - 1) >= 0) do
              Map.put(acc, j, (i - 1))
            else
              if (j == 4) && (rem((i + 1) , magicN) != 0) && ((i+1)< n) do
                Map.put(acc, j, (i + 1))
              else
                if (j == 5) && (i + (magicN * magicN) < n) do
                  Map.put(acc, j, (i + (magicN * magicN)))
                else
                  if (j == 6) && (i - (magicN * magicN) >= 0) do
                    Map.put(acc, j, (i - (magicN * magicN)))
                  else
                      acc 
                  end
                end
              end
            end
          end
        end
      end)

      neighbors = Map.values(neighbors)

      neighbors =
      case topology do
        "imp3D" -> neighbors ++ get_random_node(neighbors, i, n-1) 
        _ -> neighbors
      end

      neighbor_pids = Enum.map(neighbors, fn x ->
        {:ok, n} = Map.fetch(indexed_actors, x)
        n end)

     {:ok, actor} = Map.fetch(indexed_actors, i)
     Map.put(acc, actor, neighbor_pids)
    end)
  end
  
  #  ---------------------   Determine neighbor nodes for 2D topology  ---------------------
  def determine_nodes_2D(actors, topology) do

    n = length(actors)
    magicN = trunc(:math.ceil(:math.sqrt(n)))
    indexed_actors = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({y,magicN}, acc) -> Map.put(acc, magicN, y) end)

    #final_neighbors = Enum.reduce(0..n-1, %{}, fn i,acc ->
    Enum.reduce(0..n-1, %{}, fn i,acc ->
      neighbors = Enum.reduce(1..4, %{}, fn (j, acc) ->
        if (j == 1) && ((i - magicN) >= 0) do
          Map.put(acc, j, (i - magicN))
        else
          if (j == 2) && ((i + magicN) < n) do
            Map.put(acc, j, (i+magicN))
          else
            if (j == 3) && (rem((i - 1), magicN) != (magicN - 1)) && ((i - 1) >= 0) do
              Map.put(acc, j, (i - 1))
            else
              if (j == 4) && (rem((i + 1) , magicN) != 0) && ((i+1)< n) do
                Map.put(acc, j, (i + 1))
              else
                acc 
              end
            end
          end
        end
      end)

      neighbors = Map.values(neighbors)

      neighbors =
      case topology do
        "rand2D" ->
           neighbors ++ get_random_node(neighbors, i, n-1) 
        _ -> neighbors
      end

      neighbor_pids = Enum.map(neighbors, fn x ->
        {:ok, n} = Map.fetch(indexed_actors, x)
        n end)

     {:ok, actor} = Map.fetch(indexed_actors, i)
     Map.put(acc, actor, neighbor_pids)
    end)
  end

  #  ---------------------   Determine neighbor nodes for Torus topology  ---------------------
  def determine_nodes_torus(actors) do
    n = length(actors)
    indexed_actors = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({y,magicN}, acc) -> Map.put(acc, magicN, y) end)
    
    {ringPts, tubePts}=
    cond do
      n >= 10000 ->
         {1000, trunc(:math.ceil((1/1000) * n))}
      n >= 1000 && n < 10000 ->
         {100, trunc(:math.ceil((1/100) * n))}
      n < 1000 ->
         {10, trunc(:math.ceil((1/10) * n))}
    end

    Enum.reduce(0..ringPts-1, %{}, fn r, acc ->
      Enum.reduce(0..tubePts-1, acc, fn t, acc ->
        i = r + t * ringPts
        if(i<n) do
          neighbors = []
          neighbor1 = (r-1) + t * ringPts
          neighbors =
          if(neighbor1 > 0 && neighbor1 < n) do
             neighbors ++ [neighbor1]
          else
             neighbors
          end
          neighbor2 = (r+1) + t * ringPts
          neighbors =
          if(neighbor2 > 0 && neighbor2 < n) do
             neighbors ++ [neighbor2]
          else
             neighbors
          end
          neighbor3 = (r-1) + (t-1) * ringPts
          neighbors =
          if(neighbor3 > 0 && neighbor3 < n) do
             neighbors ++ [neighbor3]
          else
            neighbors
          end
          neighbor4 = (r+1) + (t+1) * ringPts
          neighbors =
          if(neighbor4 > 0 && neighbor4 < n) do
             neighbors ++ [neighbor4]
          else
            neighbors
          end
          neighbor5 = r + (t-1) * ringPts
          neighbors =
          if(neighbor5 > 0 && neighbor5 < n) do
              neighbors ++ [neighbor5]
          else
              neighbors
          end
          neighbor6 = r + (t+1) * ringPts
          neighbors =
          if(neighbor6 > 0 && neighbor6 < n) do
              neighbors ++ [neighbor6]
          else
              neighbors
          end
          neighbor7 = (r + 1) + ((t - 1) * ringPts)
          neighbors =
          if(neighbor7 > 0 && neighbor7 < n) do
              neighbors ++ [neighbor7]
          else
              neighbors
          end
          neighbor8 = (r - 1) + ((t + 1) * ringPts)
          neighbors =
          if(neighbor8 > 0 && neighbor8 < n) do
              neighbors ++ [neighbor8]
          else
              neighbors
          end
          
          #neighbors = Map.values(neighbors)

          neighbors = neighbors ++ get_random_node(neighbors, i, n-1) 
          
          neighbor_pids = Enum.map(neighbors, fn x ->
             {:ok, n} = Map.fetch(indexed_actors, x)
             n end)
          {:ok, actor} = Map.fetch(indexed_actors, i)
          Map.put(acc, actor, neighbor_pids)
        else 
          acc
        end
      end)
    end)
  end
  
  #  ------------------------   Set neighbors  ------------------------
  def set_neighbors(neighbors) do
    for  {magicN, y}  <-  neighbors  do
      Client.set_neighbors(magicN, y)
    end
  end

  #  --------   Get Random neigbor for rand2D, imp3D, impLine  --------
  def get_random_node(neighbors, i, totNodes) do
    random_node_index =  :rand.uniform(totNodes)
    neighbors = neighbors ++ [i]
    if(Enum.member?(neighbors, random_node_index)) do
      get_random_node(neighbors, i, totNodes)
    else
     [random_node_index]
    end
  end

  #  ---------------   Determine cube root of a number  ---------------
  @spec cbrt(number) :: number
  def cbrt(x) when is_number(x) do
    cube = :math.pow(x, 1/3)
    cond do
      is_float(cube) == false ->
        cube
      true ->
        cube_ceil = Float.ceil(cube)
        cube_14 = Float.round(cube, 14)
        cube_15 = Float.round(cube, 15)
        if cube_14 != cube_15 and cube_14 == cube_ceil do
          cube_14
        else
          cube
        end
    end
  end
end

