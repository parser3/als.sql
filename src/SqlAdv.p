@CLASS
Als/Sql

@OPTIONS
partial



# overwriting, so multiple calls will not cause multiple execution Sql.p/@extend[] with uses
@extend[][result]



@getCurrentDBName[][result]
^self._initConnection[]
$self.hConnection.sDB



@getObjectsList[sDBName][result;hData;sType;v]
$result[^table::create{sType	bSelected	sName	iRows	sSize	sData	sIndex	dtCreated	dtUpdated	sEngine	sComment}]

$hData[^self.getDBItems[^if(def $sDBName){$sDBName}{^self.getCurrentDBName[]}]]
^hData.foreach[sType;v]{
	^switch[$sType]{
		^case[table]{
			^v.menu{^result.append[table		$v.Name	$v.Rows	^eval($v.Data_length+$v.Index_length)	$v.Data_length	$v.Index_length	$v.Create_time	$v.Update_time	$v.Engine	^taint[$v.Comment]]}
		}
		^case[view]{
			^v.menu{^result.append[view		$v.Name								^taint[$v.Comment]]}
		}
		^case[function]{
			^v.menu{^result.append[function		$v.Name					$v.Created	$v.Modified		^taint[$v.Comment]]}
		}
		^case[procedure]{
			^v.menu{^result.append[procedure		$v.Name					$v.Created	$v.Modified		^taint[$v.Comment]]}
		}
		^case[trigger]{
			^v.menu{^result.append[trigger		$v.Trigger]}
		}
		^case[event]{
			^v.menu{^result.append[event		$v.Name]}
		}
	}
}
^result.sort{$result.sName}



@_initConnection[][result]
^if($self.hConnection.sConnectString ne $self.sConnectString){
	$self.hConnection[^self.parseConnectString[$self.sConnectString]]
}
