@CLASS
Als/Sql/MySql

@OPTIONS
partial



@parseConnectString[sConnectString][result;match;t]
# mysql://user:pwd@host:123/db?params
# mysql://user:pwd@[socket]/db?params
$t[^sConnectString.match[^^mysql://([^^:]+):([^^@]+)@(?:(?:\[([^^\^]]+)\])|(?:([^^/]+?)(?::(\d+))?))/([^^/\?]+)(?:\?(.*))?^$]]
$result[
	$.sConnectString[$sConnectString]
	$.sUser[$t.1]
	$.sPassword[$t.2]
	$.sSocket[$t.3]
	$.sHost[$t.4]
	$.sPort[$t.5]
	$.sDB[$t.6]
	$.sParams[$t.7]
]



@getOptionsString[sPurpose;hParams][result;sItems]
^self._initConnection[]
^switch[$sPurpose]{
	^case[;common]{
		$result[--user=$self.hConnection.sUser --password=$self.hConnection.sPassword^if(def $self.hConnection.sHost){ --host=$self.hConnection.sHost}^if(def $self.hConnection.sPort){ --port=$self.hConnection.sPort}^if(def $self.hConnection.sSocket){ --socket=$self.hConnection.sSocket}]
	}

	^case[export]{
		$hParams[^hash::create[$hParams]]
		^switch[$hParams.sType]{
			^case[;tables]{
				$sItems[^self.getCurrentDBName[] $hParams.sItems]
			}
			^case[databases]{
				$sItems[--databases $hParams.sItems]
			}
			^case[DEFAULT]{
				^throw[$self.CLASS_NAME;Unsupported ^$.sType value '$hParams.sType']
			}
		}
		$result[^self.getOptionsString[common;$hParams] --quick --compress --triggers --routines^if($hParams.bDropDatabase){ --add-drop-database}^if($hParams.bCreateDatabase){}{ --no-create-db}^if($hParams.bDropTable){ --add-drop-table}{ --skip-add-drop-table}^if(def $hParams.bCreateTable){ --create-options}{ --no-create-info}^switch[$hParams.sData]{^case[no data]{ --no-data}^case[insert ignore]{ --insert-ignore}^case[replace]{ --replace}} $sItems]
	}

	^case[import]{
		$hParams[^hash::create[$hParams]]
		$result[^self.getOptionsString[common;$hParams] --silent --compress --local^if(def $hParams.sFieldsTerminatedBy){ --fields-terminated-by=^self._escape[$hParams.sFieldsTerminatedBy]}^if(def $hParams.sFieldsEnclosedBy){ --^if($hParams.bFieldsEnclosedByOptionally){fields-enclosed-by}{fields-optionally-enclosed-by}=^self._escape[$hParams.sFieldsEnclosedBy]}^if(def $hParams.sFieldsEscapedBy){ --fields-escaped-by=^self._escape[$hParams.sFieldsEscapedBy]}^if(def $hParams.sLinesTerminatedBy){ --lines-terminated-by=^self._escape[$hParams.sLinesTerminatedBy]}^if(def $hParams.iIgnoreFirst){ --ignore-lines=^hParams.iIgnoreFirst.int(0)}^if($hParams.bLowPriority){ --low-priority}^if($hParams.bDelete){ --delete}^switch[$hParams.sDuplicates]{^case[insert ignore]{ --ignore}^case[replace]{ --replace}}^if(def $hParams.sCharset){ --default-character-set=$hParams.sCharset}^if($hParams.bLockTables){ --lock-tables} ^self.getCurrentDBName[]]
	}

	^case[exec]{
		$result[^self.getOptionsString[common;$hParams] --silent --compress ^self.getCurrentDBName[]]
	}
}



@_escape[sString]
$result[^sString.match[\\(?![brntZN0])][g]{\\}]]



@getDBItems[sDBName][t;iCountTotal;iSize;dtLastModified]
$t[^self.table[SHOW TABLE STATUS FROM `$sDBName`]]
$result[
	$.table[^t.select(def $t.Engine)]
	$.view[^t.select(!def $t.Engine)]
	^try{
		$.function[^self.table[SHOW FUNCTION STATUS WHERE Db = '$sDBName']]
	}{
		$exception.handled(true)
	}
	^try{
		$.procedure[^self.table[SHOW PROCEDURE STATUS WHERE Db = '$sDBName']]
	}{
		$exception.handled(true)
	}
	^try{
		$.trigger[^self.table[SHOW TRIGGERS FROM `$sDBName`]]
	}{
		$exception.handled(true)
	}
	^try{
		$.event[^self.table[SHOW EVENTS FROM `$sDBName`]]
	}{
		$exception.handled(true)
	}
]
$iCountTotal(0)
^result.foreach[;v]{
	^iCountTotal.inc(^v.count[])
}
$iSize(0)
^result.table.menu{
	^iSize.inc($result.table.Data_length + $result.table.Index_length)
}

#$dtLastModified[^Utils:getMaxDate[$result.table;Update_time]]
#$dtLastModified[^Utils:getMaxDate[$result.function;Modified;$dtLastModified]]
#$dtLastModified[^Utils:getMaxDate[$result.procedure;Modified;$dtLastModified]]

^result.add[
#	$.last-modified[$dtLastModified]
	$.count($iCountTotal)
	$.size($iSize)
]
