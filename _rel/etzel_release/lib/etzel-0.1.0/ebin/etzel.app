{application, etzel, [
	{description, ""},
	{vsn, "0.1.0"},
	{id, "v.0.2.0-7-g1b2bfea-dirty"},
	{modules, ['commonlib','datamanager','etzel_app','etzel_sup','etzeldisk','filegen','hello_handler','home_handler','login_handler','qin','servermanager','tq','uidgen','ws_handler']},
	{registered, []},
	{applications, [
		kernel,
		stdlib,
		cowboy,
		jiffy,
		eleveldb,
		mustache,
		esqlite
	]},
	{mod, {etzel_app, []}},
	{env, []}
]}.
