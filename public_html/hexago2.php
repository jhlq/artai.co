<!DOCTYPE html>
<head>
	<title>Hexago</title>
	<script src="hexagon.js"></script>
</head>
<body>

Map: <?php echo $_GET["map"]; ?><br>

<?php
	$v=$_GET["map"];
	try
	{
		$db = new PDO('sqlite:data/mapstest.sqlite');

#		$s="CREATE TABLE ".$v." (Id INTEGER PRIMARY KEY, plays TEXT, player INTEGER)";
#		$db->exec($s);	 
#		$s="INSERT INTO ".$v." (plays,player) VALUES ('0:7,9;1:5,5;0:9,7;',1);";
#		$db->exec($s);

		print "<table border=1>";
		print "<tr><td>Id</td><td>plays</td><td>player</td></tr>";
		$result = $db->query('SELECT * FROM '.$v);
		foreach($result as $row){
			print "<tr><td>".$row['Id']."</td>";
			print "<td>".$row['plays']."</td>";
			print "<td>".$row['player']."</td></tr>";
		}
		print "</table>";
		
		$result = $db->query('SELECT * FROM '.$v);
		if(empty($result))
		{
			print "This map is empty.";
		} else {
			$r=$result->fetch();
			print "This map contains the following plays: ";
			print $r['plays'];
			print '<br>';
			#print "This map contains the following plays: ".$result[0]['plays'];
			#print "The current player is: ".$result[0]['player'];
			$link='http://artai.co/hexago.php?plays='.$r['plays'].'&player='.$r['player'];
			print 'To view this map go to the following link: <a href="'.$link.'">'.$link.'</a> ';
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
