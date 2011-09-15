#!/usr/bin/perl

use URI::Escape;
require "../common/common.pm";

$file = shift;
$url_source = uri_unescape($file);
if ($url_source =~ /(\d{4})/) {
    $url_year = $1;
}
$url_source =~ s/.*html.*\/http/http/;


open FILE, $file;
@lignes = <FILE>;
close FILE;
$content = "@lignes";
$content =~ s/\n//g;
$content =~ s/(<td[^>]*>)(\s*<\/?(a|strong|p|em)[^>]*>)+/$1/gi;
$content =~ s/<\/?(a|strong|p|em)[^>]*>\s*<\/td>/<\/td>/gi;

$content =~ s/<\/(p|h[1234]|ul|div)>/<\/$1>\n/gi;

%fonctions = ();

$timestamp = 0;
$nb_seance = 0;
sub print_inter {
	if ($intervention && $intervention ne '<p></p>') {
		if ($intervention =~ /(projet de loi|texte)( n[^<]+)/) {
			$doc = $2;
			$doc =~ s/&[^;]+;//g;
			$numeros_lois = '';
			while ($doc =~ / n\s*(\d+) ?(\(\d+\-\d+\))/g) {
				$numeros_loi .= law_numberize($1,$2).",";
			}
			$numeros_loi =~ s/[^0-9\-\,]//g;
			chop($numeros_loi);
		}
		if ($intervention =~ /amendement( n[^<]+)/) {
			$doc = $1;
			$doc =~ s/&[^;]+;//g;
                        if ($doc =~ / n\s*([COM\-\d]+)/) {
				$amendements = $1;
			}
		}
		$timestamp += 20;
		$intervenant =~ s/\&nbsp;/ /g;
		print '{"commission": "'.$commission.'", "contexte": "'.$context.'", "intervention": "'.quotize($intervention).'", "timestamp": "'.$timestamp.'", "date": "'.$date.'", "source": "'.$url_source.$source.'", "heure":"'.$heure.'", "intervenant": "'.$intervenant.'", "fonction": "'.$fonction.'", "intervenant_url": "'.$url_intervenant.'", "session":"'.$session.'"';
        	print ', "numeros_loi":"'.$numeros_loi.'"' if ($numeros_loi);
	        print ', "amendements":"'.$amendements.'"' if ($amendements);
		print "}\n";
	}
	$intervenant = '';
	$fonction = '';
	$url_intervenant = '';
	$intervention = '';
	$amendements = '';
}

sub setfonction {
	my $f = shift;
	if ($f =~ /audition de (M[^<]+)/) {
		$a = $1;
		while ($a =~ /(M[me\.]* [^\,\.]+), ([^\,\.]+)/g) {
			$fonctions{$1} = $2;
		}
	}
}

$begin = 0;
foreach (split /\n/, $content) {
	$begin = 1 if (/name="toc1"/);
	$commission = $1 if (/TITLE>((Commission|Mission) [^:]*)&nbsp;:/);
	next if (!$begin);
#	print ;	print "\n";
	if (/<h2>([^<]+)<\/h2>/) {
		@date = datize($1, $url_year);
		print_inter();
		$date = join '-', @date;
		$session = sessionize(@date);
		$numeros_loi = '';
		$nb_seance = 0;
	}
	if (/<h3>([^<]+)<\/h3>/) {
		$titre = $1;
		print_inter();
		$context = $titre;
		setfonction($titre);
		$context =~ s/ - / > /;
		$intervention = '<p>'.$titre.'</p>';
		$nb_seance++;
		$heure = ($nb_seance == 1) ? '1ere' : $nb_seance.'ieme';
		$heure .= ' séance';
		%fonctions = ();
		$timestamp = 0;
		$numeros_loi = '';
		print_inter();
	}
	$source = "#$1" if (/name="([^"]+)"/);

	if (/<p[^>]*>(.*)<\/p>/i) {
		$inter = $1;
		$inter =~ s/<a[^>]*><\/a>//ig;
		$recointer = "(M\.m?e?|Amiral|Général|S\.E|Son |colonel)";
		if ($inter =~ /^<(u|strong|em)>(.*)<\/(u|strong|em)>$/i) {
			$inter = $2;
			print_inter();
	                $inter =~ s/<[^>]+>//g;
			setfonction($inter);
			$intervention = '<p>'.$inter.'</p>';
			next;
		}
		if ($inter =~ /<(a|strong)[^>]*>($recointer.*)<\/(a|strong)>/i) {
			$tmpintervenant = $2;
			$tmpintervenant =~ s/<[^>]*>//g;
			if ($tmpintervenant =~ s/^([^,]+), ([^,]*).*/$1/g) {
				$tmpfonction = $2;
				$tmpfonction =~ s/\W+$//;
				$fonctions{$tmpintervenant} = $tmpfonction;
			}else{
				$tmpfonction = $fonctions{$tmpintervenant};
			}
			print_inter() if ($tmpintervenant ne $intervenant);
			$intervenant = $tmpintervenant;
		        $fonction = $tmpfonction;
			$url_intervenant = $1 if ($inter =~ /href="([^"]+senfic\/[^"]+)"/i);
		}
		$inter =~ s/<[^>]+>//g;
		$sintervenant = $intervenant;
		$sintervenant =~ s/([\(\)\*])/\\$1/g;
		$sfonction = $fonction;
		$sfonction =~ s/([\(\)\*])/\\$1/g;
		$inter =~ s/^[^\w\&]*$sintervenant[^\w\&]*($sfonction[^\w\&]*|)//;
		$intervention .= '<p>'.$inter.'</p>' if ($inter =~ /[a-z]/i);
	}
#	print "$date $titre $source\n";
}
print_inter();
