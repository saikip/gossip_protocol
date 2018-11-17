## **GOSSIP PROTOCOL - COP5615: Fall 2018**

## **TEAM MEMBERS**
Priyam Saikia (UFID 9414 5292)
Noopur R Kalawatia (UFID 1980 9834)

## **PROBLEM**
Design gossip protocol using genserver to implement gossip algorithm for information propagation
and push-sum algorithm for sum calculation. Implement the same in various topologies. 

## **INSTALLATION AND RUN** 

Elixir Mix project is required to be installed. 
Files of importance in the zipped folder (in order of call):

go.exs             -> Commandline entry module
gossip_protocol.ex -> Main Module
Client.ex          -> Client Module
Server.ex          -> Server Module

To run a test case, do:

1. Unzip contents to your desired elixir project folder.
2. Open cmd window from this project location (use $cd <location> to change location)
3. Use "mix run go.exs <numNodes> <topology> <algorithm>" in commandline without 
   quotes to run test case. 
4. The run terminates when the algorithm converges (details in report). 
5. The result provides the time taken to converge.
6. Topologies can be: torus | 3D | rand2D | impLine | line | full
7. Algorithm can be: gossip | push-sum

Examples:
   1)
   C:\Users\PSaikia\Documents\Elixir\kv\gossip_protocol>mix run go.exs 1000 torus gossip
   Running Gossip algorithm
   Implementing torus topology
   Time to Converge: 250 ms
   
   2)
   C:\Users\PSaikia\Documents\Elixir\kv\gossip_protocol>mix run go.exs 100 rand2D push-sum
   Running Push-Sum algorithm
   Implementing random 2D topology
   Time to Converge: 94 ms

## **WHAT IS WORKING**
  Convergence of the below two algorithms are working:
    1. Gossip 
    2. Push Sum 
  
  And the algorithms are converging for all the below network topologies:
    1. Full  
    2. 3D Grid 
    3. Random 2D Grid
    4. Torus 
    5. Line 
    6. Imperfect Line 

## **LARGEST NETWORK**
    
   Largest network tested:
   
   For Gossip Algorithm
   1. Full -  7000
   2. 3D Grid  - 50,000
   3. Random 2D Grid - 50,000
   4. Torus - 50,000
   5. Line - 7000
   6. Imperfect Line - 50,000 
   
   For Push-sum Algorithm
   1. Full -  2500
   2. 3D Grid  - 5000
   3. Random 2D Grid - 5000
   4. Torus - 5000
   5. Line - 5000
   6. Imperfect Line - 5000

   
## **--------------------------------------------**--------------------------------------**
