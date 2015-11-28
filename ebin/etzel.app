{application, etzel, [
	{description, ""},
	{vsn, "0.1.0"},
	{id, "v.0.2.0-4-g78fb552-dirty"},
	{modules, ['etzel_app','etzel_sup','filegen','hello_handler','qin','tq','uidgen','ws_handler']},
	{registered, []},
	{applications, [
		kernel,
		stdlib,
		cowboy,
		jiffy,
		eleveldb,
		mustache

	]},
	{mod, {etzel_app, []}},
	{env, []}
]}.
