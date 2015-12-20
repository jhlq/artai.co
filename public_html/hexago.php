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
	Tiles: <input type="number" id="tiles" value=<?php
	$v=$_GET["tiles"];
	if ($v==""){
		echo "19";
	}else{
		echo $v;
	}?>>
	Tilesize: <input type="number" id="tilesize" value=<?php
	$v=$_GET["tilesize"];
	if ($v==""){
		echo "21";
	}else{
		echo $v;
	}?>>
	Colors: <input type="string" id="colors" value=<?php
	$v=$_GET["colors"];
	if ($v==""){
		echo "255,0,0;0,255,0;0,0,255;0,0,0;150,0,150;255,255,0;";
	}else{
		echo $v;
	}?>>
	<br>
	Border.<br>
	Start: <input type="number" id="borderstart" value=<?php
	$v=$_GET["borderstart"];
	if ($v==""){
		echo "5";
	}else{
		echo $v;
	}?>>
	Length: <input type="number" id="borderlength" value=<?php
	$v=$_GET["borderlength"];
	if ($v==""){
		echo "10";
	}else{
		echo $v;
	}?>>
	Color: <input type="string" id="bordercolor" value=<?php
	$v=$_GET["bordercolor"];
	if ($v==""){
		echo "51,0,100";
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
    </script>

</body>
