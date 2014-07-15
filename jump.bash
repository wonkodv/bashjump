bashjump_sql(){
	sqlite3 "$BASHJUMP_HISTORY" "$1"
}

bashjump_cd(){
	builtin cd "${1:-$HOME}"
	bashjump_sql "INSERT INTO jumps (dir,prio) VALUES ( '$(bashjump_escape s "$PWD")' , 1 ) ;" &>/dev/null  ||
	bashjump_sql "UPDATE  jumps SET prio = prio + 1 where dir = '$(bashjump_escape s "$PWD")';" &>/dev/null
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
						change to directory which contains all patterns in order.
						placeholders:
							_ for one character
							% for 0 or more
					j -r pattern*
						print all matches for pattern
					j -q
						print final pattern
					j -a [dir]
						add dir or pwd to table
					j -p [prio] [dir]
						increase priority of dir or pwd by prio or 10
					j -P [prio] [dir]
						set priority of pwd or dir to prio or 10
				" | sed 's/^\t\t\t\t//'
				return
			;;
			*)
				q="${q}$(bashjump_escape l "$x")%"
			;;
		esac
	done
	$opt_query && echo "query: $q" && return
	$opt_results && sqlite3 -separator "	" "$BASHJUMP_HISTORY" "SELECT prio,dir FROM jumps WHERE dir LIKE '$q' ORDER BY prio-length(dir) DESC" && return
	d="`bashjump_sql "SELECT dir FROM jumps WHERE dir LIKE '$q' ORDER BY prio-length(dir) DESC LIMIT 1"`"
	if [ -d "$d" ]
	then
		cd "$d"
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
if [ ! -f "$BASHJUMP_HISTORY" ]
then
	if ! sqlite3 "$BASHJUMP_HISTORY" "CREATE TABLE jumps(
		dir STRING PRIMARY KEY NOT NULL,
		prio INT NOT NULL
	);"
	then
		echo "problems"
		return 1
	fi
fi
}
