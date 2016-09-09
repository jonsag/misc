#!/bin/sh

# This script is ISC licensed. Use "tail -13 SVTPlay.sh" to read more.

rev=2012-09-03

## Några defaultvärden. Hellre än att ändra dem nedan,
## direkt i källkoden, bör du använda motsvarande miljö-
## variabler. (Kör "SVTPlay.sh -H" för att läsa om dem.)
PLAYER=mplayer
player_args=""
player_quiet_arg="-really-quiet"
default_bitrate=99999
convert_subs=""

## Detta är inte defaultvärden, och de kan inte ändras med
## med mindre än att skriptet slutar fungera som det ska.
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
        stderr "Fel: Hittade ingen uppspelare. Ange fullständig sökväg"
        stderr "     till en uppspelare i miljövariabeln SVTPLAY_PLAYER"
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
Användning: SVTPlay.sh [-aAcdeEhHilLOpqQrstuUvwx]
                       [-b <bitrate>]
                       [-W <url>]
                       [-o out.mp4]
                       <url> <...>
EOF
}

usage_long () {
    usage
cat << EOF

    Om skriptet körs utan flaggor spelas videon från <url> upp.

    Åtgärder:
    -d  Spara till fil i stället för att spela upp.
    -o  Filnamn att spara till. Default är som på sajten. Implicerar -d.
            OBS: Mellanslag i filnamn fungerar inte, ens med
            citationstecken runt. Detta för att behålla kompatibilitet
            med andra getopt(1)-varianter är GNU getopt.
    -O  Som -o, fast läser in filnamn från stdin. (Tillåter mellanslag.)
    -p  Spela upp strömmen även om den samtidigt sparas till disk.
    -r  Tolka <url> som rtmp-ström i stället för webbsida.
    -a  Hämta eventuell undertextfil innan video hämtas.
    -A  Hämta enbart eventuell undertextfil.
    
    Strömval:
    -b  Maximal bitrate att spela upp eller ladda hem.
        Default är '$default_bitrate', lägsta tillgängliga fås med '0'.
    -l  Tvinga hämtning som live-ström.
    -L  Tvinga hämtning som sökbar ström (dvs inte live).
    -W  Tvinga adress till SWF-spelare.

    Information:
    -e  Visa samtliga tillgängliga strömmar.
    -E  Visa den ström som väljs för uppspelning.
    -i  Visa all tillgänglig information om videon.
    -s  Visa tillgängliga bitrates.
    -t  Visa adress till undertextfil.
    -w  Visa adress till SWF-spelare.

    Skript-beteende:
    -c  Skriptbar utmaning, för informationsflaggor. Se även -x.
    -q  Skriptet pratar inte. (Dock tystas ej anropade program.)
    -Q  Som -q, men även anropade program tystas.
    -x  Torrkörning. Stannar före uppspelning/nedladdning.

    Övrigt:
    -h  Visa lång hjälptext. (Den du läser nu.)
    -H  Visa ännu längre hjälptext. (En tutorial också.)
    -u  Kolla efter ny version av SVTPlay.sh.
    -U  Kolla efter ny version och uppdatera automatiskt.
    -v  Skriv ut debug-information.

EOF
}

usage_verylong () {
    usage_long
    cat << EOF
Några exempel följer.


UPPSPELNING

  Detta spelar upp senaste Rapport-sändningen:

    \$ SVTPlay.sh http://www.svtplay.se/rapport


NEDLADDNING

  Detta sparar ett litet klipp om myggbekämpning,
  till filen "helt-i-sticket.flv":

    \$ SVTPlay.sh -o helt-i-sticket.flv http://www.svtplay.se/klipp...


LIVE-SÄNDNINGAR

  Så här gör du för att se senaste sändningen av Aktuellt:

    \$ SVTPlay.sh -l http://www.svtplay.se/aktuellt

  Om en livesändning pågår för tillfället, så känner skriptet
  av detta automatiskt.

  Eftersom senaste sändningen av Aktuellt alltid ligger på den
  sidan så fungerar raden dessutom alltid.


BITRATES

  Så här kollar du vilka bitrates Aktuellt finns i:

    \$ SVTPlay.sh -s http://www.svtplay.se/aktuellt
    Hämtar information om strömmar...
    Analyserar information...
    Letar efter undertexter...
    Hämtar adress till SWF-spelare...
    Bitrates:     320 850

  Nu kör vi den lägre:

    \$ SVTPlay.sh -b 320 http://www.svtplay.se/aktuellt

  Ett sätt att alltid få den lägsta kvaliteten är så här:

    \$ SVTPlay.sh -b 0 http://www.svtplay.se/aktuellt


KÖRA RTMP-ADRESSER DIREKT

  Så här kan du lista ut rtmp-adressen till ett program:

    \$ SVTPlay.sh -Ex http://www.svtplay.se/aktuellt
    Hämtar information om strömmar...
    Analyserar information...
    Letar efter undertexter...
    Hämtar adress till SWF-spelare...
    Ström: rtmp://fl11.c91005.cdn.qbrick.com/91005/_definst_/wp...

  Med "-r" kan man spela eller ladda ned en dylik rtmp- eller
  http-ström utan omsvep:

    \$ SVTPlay.sh -ro aktuellt.mp4 rtmp://fl11.c91005.cdn.qbric...

  Med "-W" kan man tvinga SVTPlay.sh att använda en viss url
  till SWF-spelare. Detta fungerar både vid normal användning
  och om du angivit en direktadress till en ström med "-r":

    \$ SVTPlay.sh -ro aktuellt.mp4 -W http://www.svtplay.se/pub...


ANVÄNDA SVTPlay.sh I SKRIPT

  För "-e", "-E", "-s", "-t", "-w" och "-x" gäller att parametern
  "-c" bara matar ut det riktigt väsentliga.

    \$ SVTPlay.sh -csx http://www.svtplay.se/aktuellt
    320 850
    \$ SVTPlay.sh -cEx http://www.svtplay.se/aktuellt
    rtmp://fl11.c91005.cdn.qbrick.com/91005/_definst_/wp3/12819...


UPPDATERINGAR

  Har du varit förnuftig nog att göra SVTPlay.sh körbar samt
  nåbar via PATH, så kan du uppdatera automatiskt, så här:
  
    \$ SVTPlay.sh -U

  Om LC_CTYPE innehåller 'utf' kommer det uppdaterade skriptet
  att teckenkodas som UTF-8, annars som ISO-8859-1.
  
  För att hämta den senaste verionen av skriptet manuellt kan
  följande rader användas, för cURL respektive wget.

    \$ curl -o ny-SVTPLAY.sh \$(SVTPlay.sh -u)

    \$ wget -O ny-SVTPLAY.sh \$(SVTPlay.sh -u)


KONFIGURATION

  I stället för att konfigurera skriptet genom att ändra det, så
  kan du uppnå samma resultat med följande miljövariabler:

    SVTPLAY_PLAYER             Mediaspelare
                               Default: '$PLAYER'

    SVTPLAY_PLAYER_ARGS        Parametrar för mediaspelaren
                               Default: '$player_args'

    SVTPLAY_PLAYER_QUIET_ARG   Parameter för att tysta mediaspelaren
                               Default: '$player_quiet_arg'

    SVTPLAY_BITRATE            Förinställd maximal bitrate att använda
                               Default: '$default_bitrate'

    SVTPLAY_WIDESCREEN         "Lyfter" bilden på bredbildsskärmar
                               Fungerar endast med mplayer.
                               Default: 'false'

    SVTPLAY_SUBCONVERT         Kommando som körs efter att varje
                               undertextfil hämtas. Kommer köras med
                               undertextfilens namn som enda parameter.
                               Default: (inget)

    SVTPLAY_CHECK_FOR_UPDATE   Sätt till 'true' för att kolla efter
                               uppdateringar varje körning, oavsett
                               om flaggan '-u' använts.
                               Default: 'false'

EOF
}

# Pick up environment vars
if [ X"$SVTPLAY_WIDESCREEN" = Xtrue ]; then
    wide="-vf expand=::0:0:1:8/5:"
    stdebug Widescreen-hack påslaget
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
    stdebug Min miljö är tyvärr Windows.
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
            stderr "Ange filnamn att skriva till. Om filen redan finns så kommer den att ersättas."
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

stdebug PLAYER är $PLAYER
stdebug player_args är $player_args
stdebug player_quiet_arg är $player_quiet_arg
stdebug default_bitrate är $default_bitrate

hascommand which

## Need curl or wget
if [ X$(which curl 2> /dev/null) != X ]; then
    GET="$(which curl) -s"
    GETO="$(which curl) -o"
    stdebug "Använder curl."
elif [ X$(which wget 2> /dev/null) != X ]; then
    GET="$(which wget) -q -O-"
    GETO="$(which wget) -O"
    stdebug "Använder wget."
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
		stdebug "LC_CTYPE innehåller 'utf', använder script url med ?encoding=utf-8"
		script_url="$script_url?encoding=utf-8"
	else
		stdebug "Ohanterat värde av LC_CTYPE, använder rå script url"
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
    stderr "En ny version av SVTPlay.sh finns tillgänglig! ($rev -> $current_rev)"
    if [ X$automatic_update != Xtrue ]; then
        stderr "Kör '$0 -U' för att uppdatera automatiskt."
        stdout "$script_url"
        exit 0
    fi
fi
if [ X$has_update = Xtrue -a X$automatic_update = Xtrue ]; then
	hascommand mktemp
    stderr "Skapar tillfällig lagringsplats..."
    tempfile=$(mktemp)
    stderr "Hämtar och installerar ny version..."
    fail=false
    $GET "$script_url" > "$tempfile" || fail=true
    if [ X$fail = Xtrue ]; then
        stderr "Fel: Hämtningen misslyckades! Du får uppdatera för hand."
        stderr "     Adress: $script_url"
        exit 1
    fi
    chmod +x "$tempfile" || fail=true
    if [ X$fail = Xtrue ]; then
        stderr "Fel: Kunde inte göra filen körbar. Du kan fullfölja installationen för hand:"
        stderr "     $ mv \"$tempfile\" \"$0\""
        stderr "     $ chmod +x \"$0\""
        exit 1
    fi
    cp -i "$tempfile" $0 || fail=true
    if [ X$fail = Xtrue ]; then
        stderr "Fel: Filkopiering misslyckades! Du får uppdatera för hand."
        stderr "     Adress: $script_url"
        exit 1
    fi
    exit 0
fi

## Need rtmpdump or flvstreamer
if [ X$no_playback != Xtrue -a X$dry_run != Xtrue ]; then
    stdebug "Kommer antagligen behöva hämta rtmp-ström. Letar hämtare..."
    if [ X$(which rtmpdump 2> /dev/null) != X ]; then
        STREAMER="$(which rtmpdump)"
        stdebug Använder rtmpdump från $STREAMER
        streamer_quiet_arg="-q"
        dumpver=$(rtmpdump -h  2>&1 > /dev/null|grep RTMPDump|sed 's/RTMPDump v//')
        if [ X$dumpver != X2.4 -a X$dumpver != X2.4a ]; then
            stderr "Varning: RTMPDump v$dumpver stöds inte av det här skriptet!"
            stderr "         Du bör uppdatera RTMPDump till v2.4."
        fi
    elif [ X$(which flvstreamer 2> /dev/null) != X ]; then
        STREAMER="$(which flvstreamer)"
        stdebug Använder flvstreamer från $STREAMER
        streamer_quiet_arg="-q"
        stderr "Varning: FLVstreamer fungerar inte fullt ut med SVTPlay."
        stderr "         Du bör installera RTMPDump v2.4 i stället."
    else
        stderr "Fel: Hittade varken rtmpdump eller flvstreamer i PATH."
        exit 1
    fi
else
    stdebug "Ska inte spela upp eller hämta. Letar inte hämtare."
fi

hascommand tee

for PAGE; do
    if [ X$make_url != Xtrue ]; then
        stderr "Kontrollerar strömtyp..."
        FINAL_STREAM=$PAGE
        FINAL_BITRATE=0
        if [ X$(echo "X$PAGE"|grep rtmp) != X ]; then
            FINAL_STREAMTYPE=rtmp
            stderr "Hittade RTMP-ström."
        else if [ $(echo "X$PAGE"|grep http) != X ]; then
                FINAL_STREAMTYPE=http
                stderr "Hittade HTTP-ström."
            else
                stderr "Hittade inget att hämta där."
                exit 1
            fi
        fi
    else
        stderr "Hämtar information om strömmar..."
        stdebug $GET "$PAGE?output=json"
        JSON=$($GET "$PAGE?output=json")
        if [ X != X"$(echo $JSON | grep 'sidan finns inte' )" ]; then
            stderr "Fel: Kan inte hämta. Var länken verkligen korrekt?"
            exit 1
        fi
        if [ X != X"$(echo $JSON | grep '"live":true')" ]; then
            live=true
            stderr Strömmen är live.
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
            stdebug "Strömtyp:    $streamtype"
            if [ X$streamtype != Xrtmp -a X$streamtype != Xhttp ]; then
                stderr "Ignorerar $streamtype-ström: $url"
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
            stderr "Hittade ingen användbar ström."
			exit 1
        fi

        stdebug "Kommer använda $FINAL_STREAMTYPE-ström:"
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
            stderr "Hämtar adress till SWF-spelare..."
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
        stderr "Ström:        '$FINAL_STREAM'"
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
        stderr "Strömmar:     "
        for stream in $STREAMS; do
            stderr "               '$stream'"
        done
    fi
    if [ X$dry_run = Xtrue ]; then
        stdebug Torrkörning. Angriper nästa url.
        continue
    fi

    if [ X"$outfile" = X ]; then
        outfile=$(basename "$FINAL_STREAM")
        stdebug Bas för filnamn blir \"$outfile\".
    fi

    if [ X$get_subtitles = Xtrue ]; then
        if [ X$SUBTITLES = X ]; then
            stderr Inga undertexter hittades.
        else
            stderr Hämtar undertexter...
            sub_outfile=$(echo $outfile | \
                sed 's/^\(.*\)\.[a-z1-9]*$/\1/g'
            )$SUB_SUFFIX
            stdebug Hämtar undertexter till \"$sub_outfile\"...
            $GET "$SUBTITLES" > "$sub_outfile"
            if [ X"$convert_subs" != X ]; then
                stderr Kör extern undertext-konvertering...
                "$convert_subs" "$sub_outfile"
            else
                stdebug Ingen undertext-konvertering...
            fi
        fi
    fi

    if [ X$no_playback = Xtrue ]; then
        stdebug Ingen uppspelning/nedladdning. Angriper nästa url.
        continue;
    fi

    streamer_args="$streamer_args $SWFVFY"

    if [ X$call_quiet = Xtrue ]; then
        streamer_args=$streamer_args" $streamer_quiet_arg"
        player_args=$player_args" $player_quiet_arg"
    fi

    stdebug streamer_args är "$streamer_args"
    stdebug player_args är "$player_args"

    if [ X$download = Xfalse ]; then
        noplayerp
        if [ X$FINAL_STREAMTYPE = Xrtmp ]; then
            if [ X$windows = Xtrue ]; then
                stderr "Försöker spela upp i Windows. Håll i dig..."
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
                kill -9 $streamer_pid    # rtmpdump gillar att hänga kvar
            fi
        else
            stdebug "$PLAYER" $player_args $wide $cache -- "$FINAL_STREAM"
            "$PLAYER" $player_args $wide $cache -- "$FINAL_STREAM"
        fi
    else
        if [ X$play_override = Xtrue ]; then
            noplayerp
            if [ X$windows = Xtrue ]; then
                stderr "Försöker spela upp i Windows. Håll i dig..."
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

# Copyright (c) 2011-2012 Jesper Räftegård <jesper alfakrull huggpunkt.org>
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
