#!/bin/sh

# This script is ISC licensed. Use "tail -13 SVTPlay.sh" to read more.

rev=2012-09-03

## N�gra defaultv�rden. Hellre �n att �ndra dem nedan,
## direkt i k�llkoden, b�r du anv�nda motsvarande milj�-
## variabler. (K�r "SVTPlay.sh -H" f�r att l�sa om dem.)
PLAYER=mplayer
player_args=""
player_quiet_arg="-really-quiet"
default_bitrate=99999
convert_subs=""

## Detta �r inte defaultv�rden, och de kan inte �ndras med
## med mindre �n att skriptet slutar fungera som det ska.
video_type="flash|ios"
show_bitrates=false
show_subtitles=false
show_stream=false
show_streams=false
show_swfplayer=false
force_swfplayer=false
FORCED_SWFPLAYER=""
SUB_SUFFIX=.wsrt
get_subtitles=false
no_playback=false
live=""
force_live=false
force_notlive=false
make_url=true
download=false
outfile=""
play_override=false
dry_run=false
quiet=false
call_quiet=false
scriptable=false
streamer_args=""
check_for_update=false
automatic_update=false
debug=false

## Basic output functions.
stdout () {
    if [ X$quiet = Xfalse -o X$quiet = Xtrue -a X$scriptable = Xtrue ]; then
        echo "$*"
    fi
}
stderr () {
    if [ X$quiet = Xfalse ]; then
        echo "$*" 1>&2
    fi
}
stdebug () {
    if [ X$debug = Xtrue ]; then
        echo " ($*)" 1>&2
    fi
}

## Other functions
noplayerp () {
    if [ X"$PLAYER" = X ]; then
        stderr "Fel: Hittade ingen uppspelare. Ange fullst�ndig s�kv�g"
        stderr "     till en uppspelare i milj�variabeln SVTPLAY_PLAYER"
        exit 1
    fi
}
hascommand () {
    stdebug Letar efter $1
    if [ X$(which $1 2> /dev/null) == X ]; then
        stderr "Fel: Skriptet fungerar inte utan en '$1' i PATH."
        exit 1
    fi
}

usage () {
cat << EOF
SVTPlay.sh rev $rev
Anv�ndning: SVTPlay.sh [-aAcdeEhHilLOpqQrstuUvwx]
                       [-b <bitrate>]
                       [-W <url>]
                       [-o out.mp4]
                       <url> <...>
EOF
}

usage_long () {
    usage
cat << EOF

    Om skriptet k�rs utan flaggor spelas videon fr�n <url> upp.

    �tg�rder:
    -d  Spara till fil i st�llet f�r att spela upp.
    -o  Filnamn att spara till. Default �r som p� sajten. Implicerar -d.
            OBS: Mellanslag i filnamn fungerar inte, ens med
            citationstecken runt. Detta f�r att beh�lla kompatibilitet
            med andra getopt(1)-varianter �r GNU getopt.
    -O  Som -o, fast l�ser in filnamn fr�n stdin. (Till�ter mellanslag.)
    -p  Spela upp str�mmen �ven om den samtidigt sparas till disk.
    -r  Tolka <url> som rtmp-str�m i st�llet f�r webbsida.
    -a  H�mta eventuell undertextfil innan video h�mtas.
    -A  H�mta enbart eventuell undertextfil.
    
    Str�mval:
    -b  Maximal bitrate att spela upp eller ladda hem.
        Default �r '$default_bitrate', l�gsta tillg�ngliga f�s med '0'.
    -l  Tvinga h�mtning som live-str�m.
    -L  Tvinga h�mtning som s�kbar str�m (dvs inte live).
    -W  Tvinga adress till SWF-spelare.

    Information:
    -e  Visa samtliga tillg�ngliga str�mmar.
    -E  Visa den str�m som v�ljs f�r uppspelning.
    -i  Visa all tillg�nglig information om videon.
    -s  Visa tillg�ngliga bitrates.
    -t  Visa adress till undertextfil.
    -w  Visa adress till SWF-spelare.

    Skript-beteende:
    -c  Skriptbar utmaning, f�r informationsflaggor. Se �ven -x.
    -q  Skriptet pratar inte. (Dock tystas ej anropade program.)
    -Q  Som -q, men �ven anropade program tystas.
    -x  Torrk�rning. Stannar f�re uppspelning/nedladdning.

    �vrigt:
    -h  Visa l�ng hj�lptext. (Den du l�ser nu.)
    -H  Visa �nnu l�ngre hj�lptext. (En tutorial ocks�.)
    -u  Kolla efter ny version av SVTPlay.sh.
    -U  Kolla efter ny version och uppdatera automatiskt.
    -v  Skriv ut debug-information.

EOF
}

usage_verylong () {
    usage_long
    cat << EOF
N�gra exempel f�ljer.


UPPSPELNING

  Detta spelar upp senaste Rapport-s�ndningen:

    \$ SVTPlay.sh http://www.svtplay.se/rapport


NEDLADDNING

  Detta sparar ett litet klipp om myggbek�mpning,
  till filen "helt-i-sticket.flv":

    \$ SVTPlay.sh -o helt-i-sticket.flv http://www.svtplay.se/klipp...


LIVE-S�NDNINGAR

  S� h�r g�r du f�r att se senaste s�ndningen av Aktuellt:

    \$ SVTPlay.sh -l http://www.svtplay.se/aktuellt

  Om en lives�ndning p�g�r f�r tillf�llet, s� k�nner skriptet
  av detta automatiskt.

  Eftersom senaste s�ndningen av Aktuellt alltid ligger p� den
  sidan s� fungerar raden dessutom alltid.


BITRATES

  S� h�r kollar du vilka bitrates Aktuellt finns i:

    \$ SVTPlay.sh -s http://www.svtplay.se/aktuellt
    H�mtar information om str�mmar...
    Analyserar information...
    Letar efter undertexter...
    H�mtar adress till SWF-spelare...
    Bitrates:     320 850

  Nu k�r vi den l�gre:

    \$ SVTPlay.sh -b 320 http://www.svtplay.se/aktuellt

  Ett s�tt att alltid f� den l�gsta kvaliteten �r s� h�r:

    \$ SVTPlay.sh -b 0 http://www.svtplay.se/aktuellt


K�RA RTMP-ADRESSER DIREKT

  S� h�r kan du lista ut rtmp-adressen till ett program:

    \$ SVTPlay.sh -Ex http://www.svtplay.se/aktuellt
    H�mtar information om str�mmar...
    Analyserar information...
    Letar efter undertexter...
    H�mtar adress till SWF-spelare...
    Str�m: rtmp://fl11.c91005.cdn.qbrick.com/91005/_definst_/wp...

  Med "-r" kan man spela eller ladda ned en dylik rtmp- eller
  http-str�m utan omsvep:

    \$ SVTPlay.sh -ro aktuellt.mp4 rtmp://fl11.c91005.cdn.qbric...

  Med "-W" kan man tvinga SVTPlay.sh att anv�nda en viss url
  till SWF-spelare. Detta fungerar b�de vid normal anv�ndning
  och om du angivit en direktadress till en str�m med "-r":

    \$ SVTPlay.sh -ro aktuellt.mp4 -W http://www.svtplay.se/pub...


ANV�NDA SVTPlay.sh I SKRIPT

  F�r "-e", "-E", "-s", "-t", "-w" och "-x" g�ller att parametern
  "-c" bara matar ut det riktigt v�sentliga.

    \$ SVTPlay.sh -csx http://www.svtplay.se/aktuellt
    320 850
    \$ SVTPlay.sh -cEx http://www.svtplay.se/aktuellt
    rtmp://fl11.c91005.cdn.qbrick.com/91005/_definst_/wp3/12819...


UPPDATERINGAR

  Har du varit f�rnuftig nog att g�ra SVTPlay.sh k�rbar samt
  n�bar via PATH, s� kan du uppdatera automatiskt, s� h�r:
  
    \$ SVTPlay.sh -U

  Om LC_CTYPE inneh�ller 'utf' kommer det uppdaterade skriptet
  att teckenkodas som UTF-8, annars som ISO-8859-1.
  
  F�r att h�mta den senaste verionen av skriptet manuellt kan
  f�ljande rader anv�ndas, f�r cURL respektive wget.

    \$ curl -o ny-SVTPLAY.sh \$(SVTPlay.sh -u)

    \$ wget -O ny-SVTPLAY.sh \$(SVTPlay.sh -u)


KONFIGURATION

  I st�llet f�r att konfigurera skriptet genom att �ndra det, s�
  kan du uppn� samma resultat med f�ljande milj�variabler:

    SVTPLAY_PLAYER             Mediaspelare
                               Default: '$PLAYER'

    SVTPLAY_PLAYER_ARGS        Parametrar f�r mediaspelaren
                               Default: '$player_args'

    SVTPLAY_PLAYER_QUIET_ARG   Parameter f�r att tysta mediaspelaren
                               Default: '$player_quiet_arg'

    SVTPLAY_BITRATE            F�rinst�lld maximal bitrate att anv�nda
                               Default: '$default_bitrate'

    SVTPLAY_WIDESCREEN         "Lyfter" bilden p� bredbildssk�rmar
                               Fungerar endast med mplayer.
                               Default: 'false'

    SVTPLAY_SUBCONVERT         Kommando som k�rs efter att varje
                               undertextfil h�mtas. Kommer k�ras med
                               undertextfilens namn som enda parameter.
                               Default: (inget)

    SVTPLAY_CHECK_FOR_UPDATE   S�tt till 'true' f�r att kolla efter
                               uppdateringar varje k�rning, oavsett
                               om flaggan '-u' anv�nts.
                               Default: 'false'

EOF
}

# Pick up environment vars
if [ X"$SVTPLAY_WIDESCREEN" = Xtrue ]; then
    wide="-vf expand=::0:0:1:8/5:"
    stdebug Widescreen-hack p�slaget
else
    wide=""
fi
if [ X"$SVTPLAY_PLAYER" != X ]; then
    PLAYER=$SVTPLAY_PLAYER
fi
if [ X"$SVTPLAY_PLAYER_ARGS" != X ]; then
    player_args=$SVTPLAY_PLAYER_ARGS
fi
if [ X"$SVTPLAY_PLAYER_QUIET_ARG" != X ]; then
    player_quiet_arg=$SVTPLAY_PLAYER_QUIET_ARG
fi
if [ X"$SVTPLAY_BITRATE" != X ]; then
    default_bitrate=$SVTPLAY_BITRATE
fi
if [ X"$SVTPLAY_SUBCONVERT" != X ]; then
    convert_subs=$SVTPLAY_SUBCONVERT
fi
if [ X"$SVTPLAY_CHECK_FOR_UPDATE" = Xtrue ]; then
    check_for_update=true
fi

# Blank PLAYER var if it isn't valid
resolved_player=$(which "$PLAYER")
if [ X"$resolved_player" = X ]; then
    PLAYER=""
fi

# Now with Cygwin support!
if [ X"$OS" = X"Windows_NT" ]; then
    windows=true
    stdebug Min milj� �r tyv�rr Windows.
else
    windows=false
fi

args=$(getopt aAb:cdeEhHilLo:OpqQrstTuUvwW:x $*)

if [ $? -ne 0 ]; then
    usage
    exit 2
fi

set -- $args
while [ $# -ge 0 ]; do
    case "$1" in
        -a)
            get_subtitles=true; shift;;
        -A)
            get_subtitles=true
            no_playback=true; shift;;
        -b)
            default_bitrate="$2"; shift; shift;;
        -c)
            scriptable=true
            quiet=true
            call_quiet=true; shift;;
        -d)
            download=true; shift;;
        -e)
            show_streams=true; shift;;
        -E)
            show_stream=true; shift;;
        -h)
            usage_long
            exit 2; shift;;
        -H)
            usage_verylong
            exit 2; shift;;
        -i)
            show_bitrates=true
            show_subtitles=true
            show_stream=true
            show_streams=true
            show_swfplayer=true shift;;
        -l)
            force_live=true; shift;;
        -L)
            force_notlive=true; shift;;
        -o)
            outfile="$2"
            download=true; shift; shift;;
        -O)
            stderr "Ange filnamn att skriva till. Om filen redan finns s� kommer den att ers�ttas."
            read outfile
            stderr "Skriver till '$outfile'."
            download=true; shift;;
        -p)
            play_override=true; shift;;
        -q)
            quiet=true; shift;;
        -Q)
            quiet=true
            call_quiet=true; shift;;
        -r)
            make_url=false; shift;;
        -s)
            show_bitrates=true; shift;;
        -t)
            show_subtitles=true; shift;;
        -u)
            check_for_update=true; shift;;
        -U)
            check_for_update=true
            automatic_update=true; shift;;
        -v)
            debug=true;
            stdebug Debug mode on
            shift;;
        -w)
            show_swfplayer=true; shift;;
        -W)
            force_swfplayer=true;
            FORCED_SWFPLAYER="$2"; shift; shift;;
        -x)
            dry_run=true; shift;;
        --)
            shift; break;;
    esac
done

stdebug PLAYER �r $PLAYER
stdebug player_args �r $player_args
stdebug player_quiet_arg �r $player_quiet_arg
stdebug default_bitrate �r $default_bitrate

hascommand which

## Need curl or wget
if [ X$(which curl 2> /dev/null) != X ]; then
    GET="$(which curl) -s"
    GETO="$(which curl) -o"
    stdebug "Anv�nder curl."
elif [ X$(which wget 2> /dev/null) != X ]; then
    GET="$(which wget) -q -O-"
    GETO="$(which wget) -O"
    stdebug "Anv�nder wget."
else
    stderr "Fel: Hittade varken wget eller cURL i PATH."
    exit 1
fi

hascommand grep
hascommand egrep
hascommand sed

if [ X$check_for_update = Xtrue ]; then
    script_url="http://api.huggpunkt.org/SVTPlay.sh/source/master"
	if [ X$(echo $LC_CTYPE|grep -i utf) != X ]; then
		stdebug "LC_CTYPE inneh�ller 'utf', anv�nder script url med ?encoding=utf-8"
		script_url="$script_url?encoding=utf-8"
	else
		stdebug "Ohanterat v�rde av LC_CTYPE, anv�nder r� script url"
	fi
    stdebug Kollar efter uppdatering.
    current_rev=$($GET $script_url|grep "^rev="|sed "s/rev=//")
fi
if [ X"$current_rev" != X"$rev" -a X"$current_rev" != X ]; then
    has_update=true
else
    has_update=false
fi
if [ X$has_update = Xtrue -a X$quiet != Xtrue ]; then
    stderr "En ny version av SVTPlay.sh finns tillg�nglig! ($rev -> $current_rev)"
    if [ X$automatic_update != Xtrue ]; then
        stderr "K�r '$0 -U' f�r att uppdatera automatiskt."
        stdout "$script_url"
        exit 0
    fi
fi
if [ X$has_update = Xtrue -a X$automatic_update = Xtrue ]; then
	hascommand mktemp
    stderr "Skapar tillf�llig lagringsplats..."
    tempfile=$(mktemp)
    stderr "H�mtar och installerar ny version..."
    fail=false
    $GET "$script_url" > "$tempfile" || fail=true
    if [ X$fail = Xtrue ]; then
        stderr "Fel: H�mtningen misslyckades! Du f�r uppdatera f�r hand."
        stderr "     Adress: $script_url"
        exit 1
    fi
    chmod +x "$tempfile" || fail=true
    if [ X$fail = Xtrue ]; then
        stderr "Fel: Kunde inte g�ra filen k�rbar. Du kan fullf�lja installationen f�r hand:"
        stderr "     $ mv \"$tempfile\" \"$0\""
        stderr "     $ chmod +x \"$0\""
        exit 1
    fi
    cp -i "$tempfile" $0 || fail=true
    if [ X$fail = Xtrue ]; then
        stderr "Fel: Filkopiering misslyckades! Du f�r uppdatera f�r hand."
        stderr "     Adress: $script_url"
        exit 1
    fi
    exit 0
fi

## Need rtmpdump or flvstreamer
if [ X$no_playback != Xtrue -a X$dry_run != Xtrue ]; then
    stdebug "Kommer antagligen beh�va h�mta rtmp-str�m. Letar h�mtare..."
    if [ X$(which rtmpdump 2> /dev/null) != X ]; then
        STREAMER="$(which rtmpdump)"
        stdebug Anv�nder rtmpdump fr�n $STREAMER
        streamer_quiet_arg="-q"
        dumpver=$(rtmpdump -h  2>&1 > /dev/null|grep RTMPDump|sed 's/RTMPDump v//')
        if [ X$dumpver != X2.4 -a X$dumpver != X2.4a ]; then
            stderr "Varning: RTMPDump v$dumpver st�ds inte av det h�r skriptet!"
            stderr "         Du b�r uppdatera RTMPDump till v2.4."
        fi
    elif [ X$(which flvstreamer 2> /dev/null) != X ]; then
        STREAMER="$(which flvstreamer)"
        stdebug Anv�nder flvstreamer fr�n $STREAMER
        streamer_quiet_arg="-q"
        stderr "Varning: FLVstreamer fungerar inte fullt ut med SVTPlay."
        stderr "         Du b�r installera RTMPDump v2.4 i st�llet."
    else
        stderr "Fel: Hittade varken rtmpdump eller flvstreamer i PATH."
        exit 1
    fi
else
    stdebug "Ska inte spela upp eller h�mta. Letar inte h�mtare."
fi

hascommand tee

for PAGE; do
    if [ X$make_url != Xtrue ]; then
        stderr "Kontrollerar str�mtyp..."
        FINAL_STREAM=$PAGE
        FINAL_BITRATE=0
        if [ X$(echo "X$PAGE"|grep rtmp) != X ]; then
            FINAL_STREAMTYPE=rtmp
            stderr "Hittade RTMP-str�m."
        else if [ $(echo "X$PAGE"|grep http) != X ]; then
                FINAL_STREAMTYPE=http
                stderr "Hittade HTTP-str�m."
            else
                stderr "Hittade inget att h�mta d�r."
                exit 1
            fi
        fi
    else
        stderr "H�mtar information om str�mmar..."
        stdebug $GET "$PAGE?output=json"
        JSON=$($GET "$PAGE?output=json")
        if [ X != X"$(echo $JSON | grep 'sidan finns inte' )" ]; then
            stderr "Fel: Kan inte h�mta. Var l�nken verkligen korrekt?"
            exit 1
        fi
        if [ X != X"$(echo $JSON | grep '"live":true')" ]; then
            live=true
            stderr Str�mmen �r live.
        else
            live=false
        fi
        if [ X$force_live = Xtrue ]; then
            live=true
        fi
        if [ X$force_notlive = Xtrue ]; then
            live=false
        fi
        STREAMBLOBS=$(echo $JSON | \
            sed 's/{"url/|{"url/g;s/.wsrt"/.wsrt"|/g' | \
			tr '|' '\n' | \
            grep '{"url' | \
            sed 's/^.*{\(.*\)}.*$/\1/g' | \
            egrep ".*\"$video_type\"$"
        )

        stderr "Analyserar information..."
        STREAMS=""
        FINAL_BITRATE=0
        low_bitrate=99999
        for BLOB in $STREAMBLOBS; do
            url=$(echo $BLOB | \
                sed 's/^.*"url":"\([^"]*\)".*$/\1/g'
            )
            bitrate=$(echo $BLOB | \
                sed 's/^.*"bitrate":\([^"]*\),.*$/\1/g'
            )
            if [ "X$(echo $url|grep -o 'manifest.f4m')" = Xmanifest.f4m ]; then
                streamtype=hds
            else
                if [ "X$(echo $url|grep -o '.m3u8$')" = X.m3u8 ]; then
                    streamtype=ios
                else
                    streamtype=$(echo $url | \
                        sed 's/^\([a-z][a-z][a-z][a-z]\).*:\/\/.*/\1/'
                    )
                fi
            fi
            stdebug "Url:         $url"
            stdebug "Bitrate:     $bitrate"
            stdebug "Str�mtyp:    $streamtype"
            if [ X$streamtype != Xrtmp -a X$streamtype != Xhttp ]; then
                stderr "Ignorerar $streamtype-str�m: $url"
                continue
            fi
            STREAMS="$url $STREAMS"
            BITRATES="$bitrate $BITRATES"
            STREAMTYPES="$streamtype $STREAMTYPES"
            
            if [ $low_bitrate -gt $bitrate ]; then
                low_bitrate=$bitrate
            fi
            if [ $bitrate -le $default_bitrate \
                        -a $FINAL_BITRATE -le $default_bitrate \
                        -a $FINAL_BITRATE -le $bitrate \
                    -o X"$FINAL_STREAM" = X \
                    -o X"$FINAL_STREAM" != X \
                        -a $FINAL_BITRATE -gt $default_bitrate \
                        -a $bitrate -lt $FINAL_BITRATE ]; then
                FINAL_BITRATE=$bitrate
                FINAL_STREAM=$url
                FINAL_STREAMTYPE=$streamtype
            fi
        done

        if [ X$FINAL_STREAM = X ]; then
            stderr "Hittade ingen anv�ndbar str�m."
			exit 1
        fi

        stdebug "Kommer anv�nda $FINAL_STREAMTYPE-str�m:"
        stdebug "Adress:    $FINAL_STREAM"
        stdebug "Bitrate:   $FINAL_BITRATE"

        stderr "Letar efter undertexter..."
        SUBTITLES=$(echo $JSON | \
            grep '.wsrt"' | \
            sed 's/^.*"\(http:\/\/.*\.wsrt\)".*$/\1/'
        )
        if [ X$SUBTITLES != X ]; then
            HAS_SUBTITLES=true
            stdebug "Undertexter: $SUBTITLES"
        else
            HAS_SUBTITLES=false
            stdebug Undertexter finns inte.
        fi

        if [ X$force_swfplayer != Xtrue ]; then
            stderr "H�mtar adress till SWF-spelare..."
            stdebug $GET "$PAGE?type=embed"
            SWFPLAYER=$($GET "$PAGE?type=embed" | \
                grep '<param name="movie"' | \
                sed 's/.*value="\([^"]*\).*/\1/'
            )
            if [ X$SWFPLAYER != X ]; then
                SWFPLAYER="http://www.svtplay.se$SWFPLAYER"
                SWFVFY="--swfVfy $SWFPLAYER"
            else
                SWFPLAYER=""
                SWFVFY=""
            fi
            stdebug "SwfPlayer:   $SWFPLAYER"
        else
            SWFPLAYER=$FORCED_SWFPLAYER
            SWFVFY="--swfVfy $SWFPLAYER"
        fi
    fi

    if [ X$scriptable = Xtrue ]; then
        if [ X$show_stream != Xfalse ]; then
            stdout "$FINAL_STREAM"
        fi
        if [ X$show_streams != Xfalse ]; then
            stdout "$STREAMS"
        fi
        if [ X$show_bitrates != Xfalse ]; then
            stdout "$BITRATES"
        fi
        if [ X$show_swfplayer != Xfalse ]; then
            stdout "$SWFPLAYER"
        fi
        if [ X$show_subtitles != Xfalse ]; then
            stdout "$SUBTITLES"
        fi
    fi
    if [ X$show_stream != Xfalse ]; then
        stderr "Str�m:        '$FINAL_STREAM'"
    fi
    if [ X$show_bitrates != Xfalse ]; then
        stderr "Bitrates:     '$BITRATES'"
    fi
    if [ X$show_swfplayer != Xfalse ]; then
        stderr "SWF-spelare:  '$SWFPLAYER'"
    fi
    if [ X$show_subtitles != Xfalse ]; then
        stderr "Undertexter:  '$SUBTITLES'"
    fi
    if [ X$show_streams != Xfalse ]; then
        stderr "Str�mmar:     "
        for stream in $STREAMS; do
            stderr "               '$stream'"
        done
    fi
    if [ X$dry_run = Xtrue ]; then
        stdebug Torrk�rning. Angriper n�sta url.
        continue
    fi

    if [ X"$outfile" = X ]; then
        outfile=$(basename "$FINAL_STREAM")
        stdebug Bas f�r filnamn blir \"$outfile\".
    fi

    if [ X$get_subtitles = Xtrue ]; then
        if [ X$SUBTITLES = X ]; then
            stderr Inga undertexter hittades.
        else
            stderr H�mtar undertexter...
            sub_outfile=$(echo $outfile | \
                sed 's/^\(.*\)\.[a-z1-9]*$/\1/g'
            )$SUB_SUFFIX
            stdebug H�mtar undertexter till \"$sub_outfile\"...
            $GET "$SUBTITLES" > "$sub_outfile"
            if [ X"$convert_subs" != X ]; then
                stderr K�r extern undertext-konvertering...
                "$convert_subs" "$sub_outfile"
            else
                stdebug Ingen undertext-konvertering...
            fi
        fi
    fi

    if [ X$no_playback = Xtrue ]; then
        stdebug Ingen uppspelning/nedladdning. Angriper n�sta url.
        continue;
    fi

    streamer_args="$streamer_args $SWFVFY"

    if [ X$call_quiet = Xtrue ]; then
        streamer_args=$streamer_args" $streamer_quiet_arg"
        player_args=$player_args" $player_quiet_arg"
    fi

    stdebug streamer_args �r "$streamer_args"
    stdebug player_args �r "$player_args"

    if [ X$download = Xfalse ]; then
        noplayerp
        if [ X$FINAL_STREAMTYPE = Xrtmp ]; then
            if [ X$windows = Xtrue ]; then
                stderr "F�rs�ker spela upp i Windows. H�ll i dig..."
                stdebug "$STREAMER" $streamer_args $live -o - -r "$FINAL_STREAM" \\
                stdebug " \|" "$PLAYER" $player_args $wide $cache "-- -"
                "$STREAMER" $streamer_args $live -o - -r "$FINAL_STREAM" \
                    | "$PLAYER" $player_args $wide $cache -- -
            else
                rm $HOME/.teve-fifo
                mkfifo $HOME/.teve-fifo
                stdebug "$STREAMER" $streamer_args $live -o $HOME/.teve-fifo -r "$FINAL_STREAM"\&
                "$STREAMER" $streamer_args $live -o $HOME/.teve-fifo -r "$FINAL_STREAM"&
                streamer_pid=$!
                stdebug "$PLAYER" $player_args $wide $cache -- $HOME/.teve-fifo
                "$PLAYER" $player_args $wide $cache -- $HOME/.teve-fifo
                kill -9 $streamer_pid    # rtmpdump gillar att h�nga kvar
            fi
        else
            stdebug "$PLAYER" $player_args $wide $cache -- "$FINAL_STREAM"
            "$PLAYER" $player_args $wide $cache -- "$FINAL_STREAM"
        fi
    else
        if [ X$play_override = Xtrue ]; then
            noplayerp
            if [ X$windows = Xtrue ]; then
                stderr "F�rs�ker spela upp i Windows. H�ll i dig..."
                if [ X$http = Xfalse ]; then
                    stdebug "$STREAMER" $streamer_args $live -o - -r "$FINAL_STREAM" \\
                    stdebug " \| tee $outfile \\"
                    stdebug " \| $PLAYER $player_args $wide $cache -- -"
                    "$STREAMER" $streamer_args $live -o - -r "$FINAL_STREAM" \
                        | tee "$outfile" \
                        | "$PLAYER" $player_args $wide $cache -- -
                else
                    stdebug $GET "$FINAL_STREAM" \| tee "$outfile" \\
                    stdebug " \| $PLAYER $player_args $wide $cache -- -"
                    $GET "$FINAL_STREAM" | tee "$outfile" \
                        | "$PLAYER" $player_args $wide $cache -- -
                fi
            else
                rm $HOME/.teve-fifo
                mkfifo $HOME/.teve-fifo
                if [ X$http = Xfalse ]; then
                    stdebug "$STREAMER $streamer_args $live -o - -r $FINAL_STREAM"
                    "$STREAMER" $streamer_args $live -o - -r "$FINAL_STREAM" \
                        | tee "$outfile" > $HOME/.teve-fifo&
                    stdebug "$PLAYER $player_args $wide $cache -- $HOME/.teve-fifo"
                    "$PLAYER" $player_args $wide $cache -- $HOME/.teve-fifo
                else
                    stdebug "$GET $FINAL_STREAM \| tee $outfile \\"
                    stdebug " > $HOME/.teve-fifo&"
                    $GET "$FINAL_STREAM" | tee "$outfile" \
                        > $HOME/.teve-fifo&
                    stdebug "$PLAYER $player_args $wide $cache -- $HOME/.teve-fifo"
                    "$PLAYER" $player_args $wide $cache -- $HOME/.teve-fifo
                fi
            fi
        else
            if [ X$FINAL_STREAMTYPE = Xrtmp ]; then
                stdebug $STREAMER $streamer_args $live -o "$outfile" -r "$FINAL_STREAM"
                "$STREAMER" $streamer_args $live -o "$outfile" -r "$FINAL_STREAM"
                if [ X$live = X ]; then
                    stdebug "$STREAMER" $streamer_args -o "$outfile" -r "$FINAL_STREAM" --resume
                    "$STREAMER" $streamer_args -o "$outfile" -r "$FINAL_STREAM" --resume
                fi
            else
                stdebug $GETO "$outfile" "$FINAL_STREAM"
                $GETO "$outfile" "$FINAL_STREAM"
            fi
        fi
    fi
done

exit

# Copyright (c) 2011-2012 Jesper R�fteg�rd <jesper alfakrull huggpunkt.org>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
