<!DOCTYPE html>
<head>
	<title>Hexago</title>
	<script src="hexagon.js"></script>
</head>
<body>

<?php
	$map=preg_replace('/[^0-9A-z_-]+/',"$1",$_GET["map"]);
	$plays=preg_replace('/[^0-9:,;]+/',"$1",$_GET["plays"]);
	$player=preg_replace('/[^0-9]+/',"$1",$_GET["player"]);
	$players=preg_replace('/[^0-9]+/',"$1",$_GET["players"]);
	$borderlength=preg_replace('/[^0-9]+/',"$1",$_GET["borderlength"]);
	$tiles=preg_replace('/[^0-9]+/',"$1",$_GET["tiles"]);
	$tilesize=preg_replace('/[^0-9]+/',"$1",$_GET["tilesize"]);
	$colors=preg_replace('/[^0-9:,;]+/',"$1",$_GET["colors"]);
	$borderstart=preg_replace('/[^0-9]+/',"$1",$_GET["borderstart"]);
	$bordercolor=preg_replace('/[^0-9:,;]+/',"$1",$_GET["bordercolor"]);
	echo "Map name: ".$map."<br>";
	$link2='http://artai.co/hexago3.php?map='.$map;
	echo 'Map link: <a href="'.$link2.'">'.$link2.'</a><br>';
	try
	{
		$db = new PDO('sqlite:data/mapstest.sqlite');

		$s="CREATE TABLE ".$map." (Id INTEGER PRIMARY KEY, plays TEXT, player INTEGER, players INTEGER, borderlength INTEGER, tiles INTEGER, tilesize INTEGER, colors TEXT, borderstart INTEGER, bordercolor TEXT)";
		$db->exec($s);	 
		$s="INSERT INTO ".$map." (plays,player,players,borderlength,tiles,tilesize,colors,borderstart,bordercolor) VALUES ('".$plays."',".$player.",".$players.",".$borderlength.",".$tiles.",".$tilesize.",'".$colors."',".$borderstart.",'".$bordercolor."');";
		$db->exec($s);
		#print $s;

		print "<br>Map history:<br>";
		print "<table border=1>";
		print "<tr><td>Id</td><td>plays</td><td>player</td><td>borderlength</td><td>borderstart</td><td>players</td></tr>";
		$result = $db->query('SELECT * FROM '.$map);
		foreach($result as $row){
			print "<tr><td>".$row['Id']."</td>";
			print "<td>".$row['plays']."</td>";
			print "<td>".$row['player']."</td>";
			print "<td>".$row['borderlength']."</td>";
			print "<td>".$row['borderstart']."</td>";
			print "<td>".$row['players']."</td></tr>";
		}
		print "</table>";


		$result = $db->query('SELECT * FROM '.$map.' ORDER BY id DESC LIMIT 1;');
		if(empty($result))
		{
			print "This map is empty.";
		} else {
			$r=$result->fetch();
			#print "This map contains the following plays: ";
			#print $r['plays'];
			print '<br>';
			#print "This map contains the following plays: ".$result[0]['plays'];
			#print "The current player is: ".$result[0]['player'];
			$link='http://artai.co/hexago.php?plays='.$r['plays'].'&players='.$r['players'].'&player='.$r['player'];
			#print 'To view this map go to the following link: <a href="'.$link.'">'.$link.'</a> ';
			$link2='http://artai.co/hexago3.php?map='.$map;
			#print '<br>Or this one: <a href="'.$link2.'">'.$link2.'</a>';
		}


		$db = NULL;
	}
	catch(PDOException $e)
	{
		print 'Exception : '.$e->getMessage();
	}
?>

</body>
</html>
