Bash Jump
=========

Type `j moz fire` instead of `cd ~/.mozilla/firefox/asdfgh.default/` or `j htt conf` instead of `cd /etc/httpd/conf/`
just like <https://github.com/joelthelion/autojump> but smaller


Setup
-------
put something like the following into your bashrc:

    BASHJUMP_HISTORY=~/.config/jumphistory.sqlite
    source ~/code/bashjump/jump.bash
    alias cd=bashjump_cd
    alias j=bashjump_jump

Install sqlite3 and in a new bash, run once:

    bashjump_check_or_create_db

Use
---

Every directory you went go to with `cd` will be added to the database,
later you can use the `j` command to change to those directories quickly.


Matching
--------
From all directories in the jump history the one is selected that:
* matches all given parameters
* has no parent directory which matches those
* has the highest priority

if the History contains for example
	5  /projects/a/
    10 /projects/a/src
    10 /projects/a/src/foo
	20 /projects/b/src
The following would match
* `j a` the first
* `j b` the last
* `j src` the last
* `j a src` the second
* `j a / /` the third

Additional Commands:
* To see what matches instead of jumping, add the -r option
* The -q option shows the Query string that is used in a SQL-LIKE
* The Placeholders _ and % can be used

Priority
--------

A directorys priority is increased by 1 with every `cd`
it can also be change with `j -p` or `j -P`

More
----

See `j -h`

