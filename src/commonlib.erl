-module(commonlib).

-export([get_random_string/2,
		get_project_uid/0,
		hash_pass/1,
        bin_to_hex/1,
         bin_to_hexstr/1,
         check_pass/3]).

get_random_string(Length, AllowedChars) ->
	
	    lists:foldl(fun(_, Acc) ->
                        [lists:nth(random:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).

get_project_uid() ->

    Str = commonlib:get_random_string(3,"ghjklmnpqrstvwxyz"),
    {Mega, Secs, _} = os:timestamp(),
    Timestamp = Mega*1000000 + Secs,
    TimestampHex = integer_to_list(Timestamp,16),

    iolist_to_binary([Str,string:to_lower(TimestampHex)]).


hash_pass(Password)->
    Salt = get_random_string(12,"1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"),
    TempPass = erlang:list_to_binary([Password,Salt]),
    Hash = crypto:hash(sha512,TempPass),
    HexHash=commonlib:bin_to_hexstr(Hash),
    {HexHash,Salt}.

check_pass(Password,DBPassword,DBSalt)->
    TempPass = erlang:list_to_binary([Password,DBSalt]),
    Hash = crypto:hash(sha512,TempPass),  
    HexHash=commonlib:bin_to_hexstr(Hash), 
    list_to_binary(HexHash)==DBPassword.

bin_to_hex(Bin)->
 io_lib:format(lists:flatten( array:to_list(array:new([{size,16},{default,"~.16b"}]))), binary_to_list(Bin)).

 bin_to_hexstr(Bin) ->
  lists:flatten([io_lib:format("~2.16.0B", [X]) || X <- binary_to_list(Bin)]).
