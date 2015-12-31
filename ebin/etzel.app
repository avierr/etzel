{application, etzel, [
	{description, ""},
	{vsn, "0.1.0"},
	{id, "v.0.2.0-16-gc2c3cbc-dirty"},
	{modules, ['checklogin_middleware','commonlib','datamanager','etzel_app','etzel_sup','etzeldisk','filegen','get_session','hello_handler','home_handler','login_handler','qin','queue_handler','queue_list_handler','servermanager','tq','uidgen','ws_handler']},
	{registered, []},
	{applications, [
		kernel,
		stdlib,
		cowboy,
		jiffy,
		eleveldb,
		mustache,
		esqlite,
		esqlite,
		cowboy_session

	]},
	{mod, {etzel_app, []}},
	{env, []}
]}.
