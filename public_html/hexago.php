<!DOCTYPE html>
<head>
    <title>Hexago</title>
    <script src="hexagon.js"></script>
</head>
<body>
	Player: <input type="number" id="player" value="0">
	Players: <input type="number" id="players" value=
<?php
	$v=$_GET["players"];
	if ($v==""){
		echo "2";
	}else{
		echo $v;
	}?>>
	Plays: <input type="string" id="plays" value=<?php
	echo $_GET["plays"];?> >
	<button onclick="playplays()">Play!</button>	
	<br>
	<canvas id="HexCanvas" width="700" height="900"></canvas>
	<br>
	Tiles: <input type="number" id="tiles" value="19">
	Tilesize: <input type="number" id="tilesize" value="21">
	Colors: <input type="string" id="colors" value="255,0,0;0,255,0;0,0,255;0,0,0;0,150,150;150,150,0;">
	<br>
	<button onclick="refresh()">Refresh</button>	
	

    <script>
	var nt = document.getElementById("tiles").value;
	var ts = document.getElementById("tilesize").value;
	var hexagonGrid = new HexagonGrid("HexCanvas", ts);
        hexagonGrid.drawHexGrid(nt, nt, 5, 5, true);
	var border="3:9,0;3:10,1;3:11,1;3:12,2;3:13,2;3:14,3;3:15,3;3:16,4;3:17,4;3:18,5;3:18,6;3:18,7;3:18,8;3:18,9;3:18,10;3:18,11;3:18,12;3:18,13;3:18,14;3:17,14;3:16,15;3:15,15;3:14,16;3:13,16;3:12,17;3:11,17;3:10,18;3:9,18;3:8,18;3:7,17;3:6,17;3:5,16;3:4,16;3:3,15;3:2,15;3:1,14;3:0,14;3:0,13;3:0,12;3:0,11;3:0,10;3:0,9;3:0,8;3:0,7;3:0,6;3:0,5;3:1,4;3:2,4;3:3,3;3:4,3;3:5,2;3:6,2;3:7,1;3:8,1;".split(";");
	for (i = 0; i < border.length-1; i++) {
		var p=border[i].split(":");
		var q=p[1].split(",");
		hexagonGrid.drawHexAtColRow(q[0],q[1],"rgba(70,50,90,0.7)");
	}
	function refresh(){
		var canvas = document.getElementById('HexCanvas');
		var context = canvas.getContext('2d');
		context.clearRect(0, 0, canvas.width, canvas.height);
		var nt = document.getElementById("tiles").value;
		var ts = document.getElementById("tilesize").value;
		var hexagonGrid = new HexagonGrid("HexCanvas", ts);
		hexagonGrid.drawHexGrid(nt, nt, 5, 5, true);
	}
	function playplays(){
		//var plays=(document.getElementById("plays").value);
		playsequence(document.getElementById("plays").value);
	}
	//playplays();
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
    </script>

</body>
