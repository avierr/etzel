-module(commonlib).

-export([get_random_string/2,
		get_project_uid/0,
		hash_pass/1]).

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
    {Hash,Salt}.