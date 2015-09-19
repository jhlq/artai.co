<!DOCTYPE html>
<html>
<head>
	<title>ARTai</title>
</head>
<body>
<h1>Music!</h1>
<h2>One take improvisations.</h2>
<p>Once the camera goes live nothing is censored. If you want a clip made just for you then make a donation to a charity of your choice or make your own charitable act and we will have an agreement.</p>

<?php
$videos = glob("*.mp4");
$nvid=count($videos);
echo '<video width="320" height="240" controls="controls" id="TheVideo">';
echo   "<source src=\"{$videos[$nvid-1]}\" type=\"video/mp4\" />";
echo 'Your browser does not support the html5 video element.';
echo '</video>';
echo '<br>';
echo '<input id="slider" type="range" min="1"' . "max=\"$nvid\"" . ' step="1" value="3">';
echo '<button onclick="playVideo();" style="cursor: pointer;">Choose</button>';
echo '<br><br>';
echo '<script type="text/javascript">';
echo 'vid = document.querySelector("#TheVideo");';
$vidstr="[";
for ($x = $nvid-1; $x >= 0; $x--) {
	$vidstr=$vidstr  . "\"" . $videos[$x]  . "\"";
	if ($x>0){
		$vidstr=$vidstr . ",";
	}
}
$vidstr=$vidstr . "]";
echo "var jsvids=$vidstr;";
echo 'function playVideo() {
	slider=document.getElementById("slider");
	vid.src=jsvids[slider.value-1];
	console.log(slider.value);
	slider.value=parseInt(slider.value)+1;
//       vid.play();
    }';
echo '</script>';
for ($x = $nvid-1; $x >= 0; $x--) {
	$s=round(filesize($videos[$x])/1048576);
	echo "<a href=$videos[$x]>".basename($videos[$x])." (Size: ".$s."MB)</a><br>";
} 
?>


<br>
&lt;3

</body>
</html>
