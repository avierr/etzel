{application,ranch,
             [{description,"Socket acceptor pool for TCP protocols."},
              {vsn,"1.1.0"},
              {id, "1.1.0-dirty"},
              {modules, []},
              {registered,[ranch_sup,ranch_server]},
              {applications,[kernel,stdlib]},
              {mod,{ranch_app,[]}},
              {env,[]}]}.
