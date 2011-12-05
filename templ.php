<?php
function fillTpl($contents) {
	$fc = file_get_contents("index.tpl");
	
	$token = array('%title%', '%content%');
	
	$tpl = str_replace($token, $contents, $fc);	

	return $tpl;
}

function getLog($name) {
	$fn = pathinfo(strip_tags($_GET['show']));

	if(!file_exists($fn['filename']))
		die('you should not do bad requests');

	$c = file_get_contents($_GET['show'], "r");
	return return_formated($c);
}

function return_formated($string) {
	$find = array("/(\[??:??:??\] <)(\w+)([^>]*>)/e",
		      "/(\[??:??:??\] ! )(\w+)([^\n]*\n)/e",
		      '`((?:https?|ftp)://\S+[[:alnum:]]/?)`si',
	              '`((?<!//)(www\.\S+[[:alnum:]]/?))`si');
	$replace = array("'] <span class=\"user\">&lt;\\2&gt;</span>'",
			 "'] <span class=\"other\"> ! \\2 \\3</span>'",
		         '<a href="$1"  rel="nofollow">$1</a> ',
		         '<a href="http://$1" rel="nofollow">$1</a>');

	$uml_orig = array("\n", "ä", "Ä", "ö", "Ö", "ü", "Ü", "ß"); 
	$uml_repl = array("<br/>", "&auml;", "&Auml;", "&ouml;", "&Ouml;", "&uuml;", "&Uuml;", "&szlig;");
	$string = preg_replace($find, $replace, $string);
	$string = str_replace($uml_orig, $uml_repl, $string);

	return '<tt>'.$string.'</tt>';
}
