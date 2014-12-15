<html>
<body>
<h1>It works!</h1>

<?php

function lf() {
  if (is_apache()) {
    echo "<br>\n";
  }
  else {
    echo "\n";
  }
 }


function dlf() {
  if (is_apache()) {
    echo "<br>\n<br>\n";
  }
  else {
    echo "\n\n";
  }
}

function nl() {
  echo "\n";
}

function is_apache() {
  if (PHP_SAPI == "apache2handler") {
    return (1);
  }
}

function is_cli() {
  if (PHP_SAPI == "cli") {
    return (1);
  }
}

function show_array($array) {
  dlf();
  foreach($array as $key => $value)
    {
      echo $key." has the value ". $value;
      lf();
    }
}

function get_string_between($string, $start, $end){
  $string = " ".$string;
  $ini = strpos($string,$start);
  if ($ini == 0) return "";
  $ini += strlen($start);
  $len = strpos($string,$end,$ini) - $ini;
  return substr($string,$ini,$len);
}

$hostname = shell_exec('hostname');
echo "hostname: " . $hostname;
lf();

$system = shell_exec('uname');
echo "system: " . $system;
lf();

$kernel = shell_exec('uname -r');
echo "kernel: " . $kernel;
dlf();

$uptime = shell_exec('uptime');
//echo "uptime: " . $uptime;
//dlf();

echo "time: " . strtok($uptime, ' ');
dlf();

$up = get_string_between($uptime, "up ", "user");
$up = substr($up, 0, strrpos($up, ","));
echo "up: " . $up;
dlf();

$users = explode(", ", $uptime);
echo "users: " . substr($users[2], 0, -5);
dlf();

$load = explode(" ", substr(strrchr($uptime, ': '), 1));
echo "load past minute: " . substr($load[1], 0, -1);
lf();
echo "load past 5 minutes: " . substr($load[2], 0, -1);
lf();
echo "load past 15 minutes: " . substr($load[3], 0, -1);
lf();


?>

</body>
</html>
