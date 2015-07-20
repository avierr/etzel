% This file is part of Jiffy released under the MIT license.
% See the LICENSE file for more information.

-module(servox).
-export([starten/0]).
-on_load(starten/0).

starten() ->
    io:format("\nstartnes\n").


