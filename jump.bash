bashjump_sql(){
    sqlite3 "$BASHJUMP_HISTORY" "$1"
}

bashjump_cd(){
    builtin cd "${1:-$HOME}"
    bashjump_sql "INSERT INTO jumps (dir,prio) VALUES ( '$(bashjump_escape s "$PWD")' , 1 ) ;" &>/dev/null  ||
    bashjump_sql "UPDATE  jumps SET prio = prio + 1 where dir = '$(bashjump_escape s "$PWD")';" &>/dev/null ||
    echo "bashjump has database problems" >&2
}

bashjump_jump(){

    local q="%"
    local x
    local d
    local p

    local opt_results=false
    local opt_query=false
    while [ -n "$1" ]
    do
        x="$1"
        shift
        case $x in
            -r)
                opt_results=true
                ;;
            -q)
                opt_query=true
                ;;
            -a)
                d="$1"
                if [ -z "$d" ]
                then
                    d="$PWD"
                else
                    d=$(cd "$d" ; pwd )
                fi
                echo "add $d"
                bashjump_sql "INSERT INTO jumps (dir,prio) VALUES ( '$(bashjump_escape s "$d")' , 1 ) ;"
                return
                ;;
            -P)
                p="${1:-10}"
                d="$2"
                if [ -z "$d" ]
                then
                    d="$PWD"
                else
                    d=$(cd "$d" ; pwd )
                fi
                echo "set prio of $d to $p"
                bashjump_sql "UPDATE  jumps SET prio = '$(bashjump_escape s "$p")' where dir = '$(bashjump_escape s "$d")';"
                return
                ;;
            -p)
                p="${1:-10}"
                d="$2"
                if [ -z "$d" ]
                then
                    d="$PWD"
                else
                    d=$(cd "$d" ; pwd )
                fi
                echo "increase prio of $d by $p"
                bashjump_sql "UPDATE  jumps SET prio = prio + '$(bashjump_escape s "$p")' where dir = '$(bashjump_escape s "$d")';"
                return
                ;;
            -h)
                echo "bashJump:
                j pattern*
                change to directory which contains all patterns in order
                which does not have a parent directory that matches
                and which has the highest priority of all matches
                placeholders:
                _ for one character
                % for 0 or more
                . to only search in subdirectories of current
                j -r pattern*
                print all matches for pattern
                j -q
                print final pattern
                j -a [dir]
                add dir or pwd to table
                j -p [dir] [prio]
                increase priority of dir or pwd by prio or 10
                j -P [dir] [prio]
                set priority of pwd or dir to prio or 10
                " | sed 's/^\t\t\t\t//'
                return
                ;;
            .)
                q="$(bashjump_escape l "$PWD")${q}"
                ;;
            *)
                q="${q}$(bashjump_escape l "$x")%"
                ;;
        esac
    done

    sql_from_where_order="
        FROM
            jumps j1
        WHERE
                j1.dir LIKE '$q'
            AND
                NOT EXISTS
                (
                    SELECT
                        1
                    FROM
                        jumps j2
                    WHERE
                            j1.dir != j2.dir
                        AND
                            j2.dir LIKE '$q'
                        AND
                            1 = INSTR(j1.dir,j2.dir)
                )
        ORDER BY prio DESC
        "

    $opt_query && echo "query: $q" && return
    $opt_results && sqlite3 -separator "	" "$BASHJUMP_HISTORY" "SELECT prio,dir $sql_from_where_order" && return
    d="`bashjump_sql "SELECT dir $sql_from_where_order LIMIT 1"`"
    if [ -d "$d" ]
    then
        builtin cd "$d"
    elif [ -z "$d" ]
    then
        echo "no dir for query $q"
    else
        read -e -p "$d seems deleted, remove from history? [Y/n] " r
        if [[ "$r" != n && "$r" != "N" ]]
        then
            bashjump_sql "DELETE FROM  jumps WHERE dir LIKE '$(bashjump_escape l "$d")%'  ESCAPE '\\';"
        fi
    fi
}

bashjump_escape()
{
    local a
    a="$2"
    a="${a//\'/\'\'}"
    if [[ "$1" == "l" ]]
    then
        a="${a//\\/\\\\}"
        a="${a//%/\\%}"
    fi
    echo "$a"
}


bashjump_check_or_create_db(){
if ! bashjump_sql "SELECT 1 FROM jumps;" &> /dev/null
then
    if ! bashjump_sql "CREATE TABLE jumps(
        dir STRING PRIMARY KEY NOT NULL,
        prio INT NOT NULL
    );"
    then
        echo "problems"
        return 1
    fi
fi
}
