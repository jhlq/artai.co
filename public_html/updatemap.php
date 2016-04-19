<!DOCTYPE html>
<head>
	<title>Hexago</title>
	<script src="hexagon.js"></script>
</head>
<body>

<?php
	$map=$_GET["map"];
	$plays=$_GET["plays"];
	$player=$_GET["player"];
	$players=$_GET["players"];
	$borderlength=$_GET["borderlength"];
	$tiles=$_GET["tiles"];
	$tilesize=$_GET["tilesize"];
	$colors=$_GET["colors"];
	$borderstart=$_GET["borderstart"];
	$bordercolor=$_GET["bordercolor"];
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
		print $s;

		print "<br>Successfully updated map!<br><br>";

		print "Map history:<br>";
		print "<table border=1>";
		print "<tr><td>Id</td><td>plays</td><td>player</td><td>borderlength</td><td>players</td></tr>";
		$result = $db->query('SELECT * FROM '.$map);
		foreach($result as $row){
			print "<tr><td>".$row['Id']."</td>";
			print "<td>".$row['plays']."</td>";
			print "<td>".$row['player']."</td>";
			print "<td>".$row['borderlength']."</td>";
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
			print 'To view this map go to the following link: <a href="'.$link.'">'.$link.'</a> ';
			$link2='http://artai.co/hexago3.php?map='.$map;
			print '<br>Or this one: <a href="'.$link2.'">'.$link2.'</a>';
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
