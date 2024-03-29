<?php
define("LOGDIR", "./logs/");

main();
/**
* Ich bin die Mainfunktion und werde beim Starten dieses Scripts ausgefuehrt
*/
function main() {
	$fn = pathinfo(strip_tags($_GET['show']));
	$fn = $fn['filename'];

	if(isset($_GET['show'])) {
		if($fn == "latest")
			$fn=getLatestFile();
		$title = "Log vom " . $fn;
		$content = getLog($_GET['show']);
	} else {
		$title = "Channellog";
		$files = @scandir(LOGDIR);
		rsort($files);
		foreach($files AS $file) 
			if (!strstr($file, "."))
			{
				$day = substr($file, 5, 2)%2;
				$content .= "<tt class='color".$day."'><a href=show/$file>$file</a><br /></tt>";
			}
	}
	echo fillTpl(array($title, $content));
}

/**
* Ich tue die daten aus dem Array title,contents
* in das template index.tpl
*/
function fillTpl($contents) {
	$fc = file_get_contents("index.tpl");
	$token = array('%title%', '%content%');
	$tpl = str_replace($token, $contents, $fc);	
	return $tpl;
}

/**
* Ich finde die neuste Logdatei anhand ihres names im format YYYY-MM-DD
*/
function getLatestFile() {
	$files = @scandir(LOGDIR);
	rsort($files);
	return $files[0];
}

/**
* Ich lese die Daten aus der Datei mit dem uebergebenen Namen ein
*/
function getLog($name) {
	$fn = pathinfo(strip_tags($_GET['show']));
	$fn = $fn['filename'];

	if($fn == "latest") {
		$fn = getLatestFile();
	}

	if(!is_file(LOGDIR.$fn))
		die('you should not do bad requests');

	$c = file_get_contents(LOGDIR.$fn, "r");
	return return_formated($c);
}

/**
* Ich formatiere das uebergebene Chattlog
*/
function return_formated($string) {
	
	$find = array('/(\[??:??:??\] &lt;)(\w+)([^&gt;]*&gt;)/e',
		      "/(\[??:??:??\] ! )(\w+)([^\n]*\n)/e",
		      '`((?:https?|ftp)://\S+[[:alnum:]]([^&gt;\)])/?)`si',
	              '`((?<!//)(www\.\S+[[:alnum:]]([^&gt;\)])/?))`si');
	$replace = array("'] <span class=\"user\">&lt;\\2&gt;</span>'",
			 "'] <span class=\"other\"> ! \\2\\3</span>'",
		         '<a href="$1" rel="nofollow">$1</a>',
		         '<a href="http://$1" rel="nofollow">$1</a>');

	$uml_orig = array("\n", "ä", "Ä", "ö", "Ö", "ü", "Ü", "ß"); 
	$uml_repl = array("<br />\n" ,"&auml;", "&Auml;", "&ouml;", "&Ouml;", "&uuml;", "&Uuml;", "&szlig;");
	$string = htmlspecialchars($string);
	$string = preg_replace($find, $replace, $string);
	$string = str_replace($uml_orig, $uml_repl, $string);

/*	$string = explode('</span>', $string);
	print_r($string);
	foreach($string as &$str) {
		$str = "<a name=".md5($str)." href=#".md5($str).">".$str."</a>";
	}
	$string = implode($string);
*/
	return '<tt>'.$string.'</tt>';
}
