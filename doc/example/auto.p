###############################################################################
@USE
vendor/autoload.p



###############################################################################
@auto[]
#	Use Als/Sql/MySqlComp if you use in your code old name convention style
#	(last_insert_id) instead of new ones (lastInsertId).
$oSql[^Als/Sql/MySql::create[$SQL.connect-string;
	$.bDebug(1)
	$.sCacheDir[/../data/sql_cache]
	$.dCacheInterval(1/24)
]]
#end @auto[]


###############################################################################
@postprocess[sBody]
^self.getSQLStat[$oSql]
#end @postprocess[]


###############################################################################
@getSQLStat[oSql][locals]
^if(def $oSql){
	$oSqlLog[^Als/Sql/SqlLog::create[$oSql]]

	^oSqlLog.log[
		$.iQueryTimeLimit(500)
		$.iQueriesLimit(25)
		$.iQueryRowsLimit(3000)
		$.bExpandExceededQueriesToLog(1)
		^if(def $form:mode && ^form:tables.mode.locate[field;debug]){
			^rem{ *** for ?mode=debug collect all queries info and store it to separate file *** }
			$.sFile[/../data/sql.txt]
			$.bAll(1)
		}{
			^rem{ *** by default we log only pages with potential problems in sql queries *** }
			$.sFile[/../data/sql.log]
		}
	]
}
#end @getSQLStat[]
