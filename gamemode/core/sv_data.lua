hook.Add("ESDatabaseReady","bhopHandleLeaderboardTablesCreate",function()
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `bhop_leaderboards` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(32), time FLOAT, map varchar(255), difficulty int(4), name varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1" )
  ES.DBQuery("CREATE TABLE IF NOT EXISTS `bhop_player` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(32), points int unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1" )
end)
