<?php
$url="https://intense-caverns-95777.herokuapp.com/";
$headerRes = get_headers($url);  //get the header response

foreach($headerRes as $val)
  if($val=="X-Frame-Options: SAMEORIGIN" || $val=="X-Frame-Options: DENY"){
    header("location:".$url); 
    exit; 
  }
//simply redirect to their website instead of showing blank frame
?>
