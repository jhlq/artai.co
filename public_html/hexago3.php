<!DOCTYPE html>
<head>
    <title>Hexago</title>
    <script src="hexagon.js"></script>
</head>
<body>
	Player: <input type="number" id="player" value=
<?php
	$def=array("player"=>"0", "players"=>"2", "plays"=>"", "tiles"=>"19", "tilesize"=>"21", "colors"=>"255,0,0;0,255,0;0,0,255;0,0,0;150,0,150;255,255,0;", "borderstart"=>"5", "borderlength"=>"10", "bordercolor"=>"51,0,100");
	$map=$_GET["map"];
	if($map!=""){
		try{
			$db = new PDO('sqlite:data/mapstest.sqlite');

			$result = $db->query('SELECT * FROM '.$map.' ORDER BY id DESC LIMIT 1;');
			if(!empty($result)){
				$r=$result->fetch();
				$def["player"]=$r["player"];
				$def["plays"]=$r["plays"];
				$def["players"]=$r["players"];
				#$def["borderlength"]=$r["borderlength"]|"10";	

				$keys = array("borderlength", "tiles", "tilesize", "colors", "borderstart", "bordercolor");
				foreach ($keys as $key) {
					if($r[$key]!="" and $r[$key]!=-1){
						$def[$key]=$r[$key];
					}
				}		
			}
			$db = NULL;
		}
		catch(PDOException $e)
		{
			print 'Exception : '.$e->getMessage();
		}
	}
	$v=$_GET["player"];
	if ($v==""){
		echo $def["player"];
	}else{
		echo $v;
	}?>>
	Players: <input type="number" id="players" value=
<?php
	$v=$_GET["players"];
	if ($v==""){
		echo $def["players"];
	}else{
		echo $v;
	}?>>
	Plays: <input type="string" id="plays" value=
<?php
	$v=$_GET["plays"];
	if ($v==""){
		echo $def["plays"];
	}else{
		echo $v;
	}?> >
	<button onclick="playplays()">Play!</button>	
	<br>
	Map name: <input type="string" id="map" value=
<?php
	$v=$_GET["map"];
	if ($v==""){
		echo "";#$def["map"];
	}else{
		echo $v;
	}?> >
	<button onclick="updatemap()">Save map</button>
	<br>
	<button onclick="undo()" style="width:90px;height:90px;">Undo.</button>
	<br>
	<canvas id="HexCanvas" width="800" height="900"></canvas>
	<br>
	Tiles: <input type="number" id="tiles" value=<?php
	$v=$_GET["tiles"];
	if ($v==""){
		echo $def["tiles"];
	}else{
		echo $v;
	}?>>
	Tilesize: <input type="number" id="tilesize" value=<?php
	$v=$_GET["tilesize"];
	if ($v==""){
		echo $def["tilesize"];
	}else{
		echo $v;
	}?>>
	Colors: <input type="string" id="colors" pattern="[0-9:,;]+" value=<?php
	$v=$_GET["colors"];
	if ($v==""){
		echo $def["colors"];
	}else{
		echo $v;
	}?>>
	<br>
	Border.<br>
	Start: <input type="number" id="borderstart" value=<?php
	$v=$_GET["borderstart"];
	if ($v==""){
		echo $def["borderstart"];
	}else{
		echo $v;
	}?>>
	Length: <input type="number" id="borderlength" value=<?php
	$v=$_GET["borderlength"];
	if ($v==""){
		echo $def["borderlength"];
	}else{
		echo $v;
	}?>>
	Color: <input type="string" id="bordercolor" pattern="[0-9:,;]+" value=<?php
	$v=$_GET["bordercolor"];
	if ($v==""){
		echo $def["bordercolor"];
	}else{
		echo $v;
	}?>>
	<br>
	<button onclick="refresh()">Refresh</button>	
	

    <script>
	var nt = document.getElementById("tiles").value;
	var ts = document.getElementById("tilesize").value;
	hexagonGrid = new HexagonGrid("HexCanvas", ts);
        hexagonGrid.drawHexGrid(nt, nt, 5, 5, true);
	drawborder(parseInt(document.getElementById("borderstart").value),parseInt(document.getElementById("borderlength").value),document.getElementById("bordercolor").value);
	function drawborder(start,length,color){
		for (i=0;i<length;i++){
			hexagonGrid.drawHexAtColRow(0,start+i,"rgba("+color+",0.9)");
			hexagonGrid.drawHexAtColRow(length*2-2,start+i,"rgba("+color+",0.9)");
		}
		for (i=1;i<length;i++){
			hexagonGrid.drawHexAtColRow(i,start-1-parseInt(i/2-0.5),"rgba("+color+",0.9)");
			hexagonGrid.drawHexAtColRow(length-1+i,start-length/2+parseInt(i/2+0.5),"rgba("+color+",0.9)");
			hexagonGrid.drawHexAtColRow(length+i-1,start-length/2+2*length-2-parseInt(i/2),"rgba("+color+",0.9)");
			hexagonGrid.drawHexAtColRow(i,start+length+parseInt(i/2)-1,"rgba("+color+",0.9)");
		}
	}
	function refresh(){
		var el = document.getElementById('HexCanvas');
		elClone = el.cloneNode(true);
		el.parentNode.replaceChild(elClone, el);
		var canvas = document.getElementById('HexCanvas');
		var context = canvas.getContext('2d');
		context.clearRect(0, 0, canvas.width, canvas.height);
		var nt = document.getElementById("tiles").value;
		var ts = document.getElementById("tilesize").value;
		hexagonGrid = new HexagonGrid("HexCanvas", ts);
		hexagonGrid.drawHexGrid(nt, nt, 5, 5, true);
		drawborder(parseInt(document.getElementById("borderstart").value),parseInt(document.getElementById("borderlength").value),document.getElementById("bordercolor").value);
		playplays();
	}
	function playplays(){
		playsequence(document.getElementById("plays").value);
	}
	function playsequence(seq){
		plays=seq.split(";");
		var c=(document.getElementById("colors").value).split(";");
		for (i = 0; i < plays.length-1; i++) {
			var p=plays[i].split(":");
			var player=p[0];
			var q=p[1].split(",");
			hexagonGrid.drawHexAtColRow(q[0],q[1],"rgba("+c[player]+",0.3)");
		}
	}
	playsequence(document.getElementById("plays").value);
	function undo(){
		plays=document.getElementById("plays").value.split(";");
		newstr="";
		for (i = 0; i < plays.length-2; i++) {
			newstr+=plays[i]+";";
		}
		document.getElementById("plays").value=newstr;
		document.getElementById("player").value-=1;
		if (document.getElementById("player").value<0){
			document.getElementById("player").value=document.getElementById("players").value-1;
		}
		refresh();
	}
	function updatemap(){
		map=document.getElementById("map").value;
		if (map!=""){
			plays=document.getElementById("plays").value;
			player=document.getElementById("player").value;
			players=document.getElementById("players").value;
			bl=document.getElementById("borderlength").value;
			tiles=document.getElementById("tiles").value;
			tilesize=document.getElementById("tilesize").value;
			colors=document.getElementById("colors").value;
			borderstart=document.getElementById("borderstart").value;
			bordercolor=document.getElementById("bordercolor").value;
			window.location = "http://artai.co/updatemap.php?map="+map+"&plays="+plays+"&player="+player+"&players="+players+"&borderlength="+bl+"&tiles="+tiles+"&tilesize="+tilesize+"&colors="+colors+"&borderstart="+borderstart+"&bordercolor="+bordercolor;
		}
	}
    </script>

</body>
