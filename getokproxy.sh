#!/bin/bash

UA="User-Agent: Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.79 Safari/535.11"
#COOKIE=cookies
#WGET="wget -q --header="$UA" --load-cookies $COOKIE --save-cookies $COOKIE"
alias WGET="wget -q --header='$UA'"
ALL=proxyall.list
OKS=proxyoks.list
TPL=index.tpl
WEB=index.html
TMP=$$.log

shopt -s expand_aliases

function getidcloak()
{
    local url='http://www.idcloak.com/proxylist/proxy-list.html'
    local pdata="country=CN&port%5B%5D=all&protocol-http=true&anonymity-low=true&anonymity-medium=true&anonymity-high=true&connection-low=true&connection-medium=true&connection-high=true&speed-low=true&speed-medium=true&speed-high=true&order=desc&by=updated"
    local pages=3
    local out=

    if [ $# -eq 0 ]; then
        echo "getproxyipcn(file)"
        return
    fi
    out=$1

    for ((ii=1; ii<=$pages; ++ii)); do
        WGET --post-data="${pdata}&page=$ii" $url -O - |
            dos2unix |
            grep '<td title="China">CN' |
            grep '<td>[0-9]*</td><td>[0-9.]*</td></tr>$' -o |
            sed 's:<[^>]*>:-:g;' |
            awk -F- '{printf("%s:%d\n", $4, $2);}' >>$out
    done
}

function getxici()
{
    local url="http://proxy.ipcn.org/proxylist.html"
    local out=

    if [ $# -eq 0 ]; then
        echo "getproxyipcn(file)"
        return
    fi
    out=$1

    for flag in nn nt; do
        WGET http://www.xici.net.co/$flag/ -O - |
            grep '<td>[0-9][0-9.]*</td>' |
            grep '[0-9.]*' -o |
            sed 'N;s:\n:\::' >>$out
    done
}

function getproxyipcn()
{
    local url="http://proxy.ipcn.org/proxylist.html"
    local out=

    if [ $# -eq 0 ]; then
        echo "getproxyipcn(file)"
        return
    fi
    out=$1

    WGET $url -O - | grep -o '^[0-9.:]*$' | sort -Ru >>$out
}

function gethaodaili()
{
    local url="http://www.haodailiip.com/guonei/"
    local pages=40
    local tmp=$$.tmp
    local out=

    if [ $# -eq 0 ]; then
        echo "getproxyipcn(file)"
        return
    fi
    out=$1

    for ((ii=1; ii<=$pages; ++ii)); do
        sleep 2
        wget -q $url/$ii -O - |
            grep '\(i0="[^"]*"\|p1=[^;]*\)' -o |
            sed '/i0/{s:k:2:g; s:f:1:g; s:j:5:g}; s:"::g;' |
            cut -d= -f2 | sed 'N; s:\n:\::;' |
            ( 
             IFS=:
             while read ip expr; do
                 if [ -z "$expr" ]; then
                     break
                 fi
                 echo "$expr" | grep '/' 2>&1 >/dev/null
                 if [ $? -ne 0 ]; then
                     echo "$ip ($expr)" 1>&2
                     break
                 fi
                 port=$(($expr))
                 echo "$ip:$port"
                 done
            ) >>$out

         n=$(wc -l $out)
         echo -e "$ii\t$n"
     done

     sort -u $out >$tmp
     mv $tmp $out
}

function getipaddr()
{
    if [ $# -eq 0 ]; then
        echo "getipaddr(ip)"
        return
    fi
    local ip=$1

    WGET "http://ip138.com/ips1388.asp?ip=$ip&action=2" -O - |
        dos2unix |
        iconv -f gbk -t utf8 -c |
        grep '<ul class="ul1">' |
        grep '<li>[^<]*' -o |
        head -n 1 |
        cut -c23-
}

function checkip()
{
    if [ $# -ne 2 ]; then
        echo "checkip(ip, port)"
        return 1
    fi
    local ip=$1
    local port=$2
    local tmp=tmp

    http_proxy="http://$ip:$port" wget -q -t 1 --timeout=2 www.baidu.com -O $tmp
    local ret=$?
    local size=0
    
    if [ -f $tmp ]; then
        size=$(du -b $tmp | cut -d$'\t' -f1)
        rm $tmp
    fi

    if [ $size -lt 80000 ]; then
        ret=1
    fi

    return $ret
}

echo "DDD $(date) start..."

cd $(dirname $0)

if [ $# -eq 0 ]; then
    getidcloak   $ALL
    getproxyipcn $ALL
    gethaodaili  $ALL
    getxici      $ALL
fi
cut -d: -f1,2 $OKS >>$ALL
sort -uR $ALL >$TMP
mv $TMP $ALL

>$OKS
allnum=$(wc -l $ALL | cut -d' ' -f1)

#head -n 50 $ALL | (
cat $ALL | (
        IFS=:
        hitnum=0
        n=0
        while read ip port; do
            addr=$(getipaddr $ip)
            echo -ne "$n/$allnum: $ip:$port\t->\t$addr ... "
            checkip $ip $port
            isup=$?
            if [ $isup -eq 0 ]; then
                hitnum=$((hitnum + 1))
                echo "OK"
                echo "$ip:$port:$addr" >>$OKS
                echo "$ip:$port:$addr" >>$OKS

                lines=$lines$(
                if [ $((n % 2)) -eq 1 ]; then
                    echo "<tr class='alt'>"
                else
                    echo "<tr>"
                fi
                echo "<td>$n</td>"
                echo "<td>$ip</td>"
                echo "<td>$port</td>"
                echo "<td>$addr</td>"
                echo "</tr>"
                )

            else
                echo "FAILED"
            fi
            n=$((n + 1))
        done
        per=$(echo -e "scale=2\n $hitnum/$allnum * 100" | bc)
        ipnum=$(cut -d: -f1 $OKS | sort -u | wc -l)
        echo "DDD RESULT: all: $allnum, hit: $hitnum, $hitnum / $allnum = $per %, ip: $ipnum"

        eval "echo \"$(< $TPL)\"" >$WEB
        )

echo "DDD $(date)  end..."

