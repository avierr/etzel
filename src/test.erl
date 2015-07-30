-module(test).
-export([stp/1]). 


%Qname = 1.

stp(Q) ->
        receive 
               Msg ->
                   io:format("T ~w ",[Q]),
                    stp(lists:append(Q,[Msg]))
        end.            
   

   
   
   
