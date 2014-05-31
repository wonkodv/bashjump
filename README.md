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

Of all directories that contain the parameters in that order, the one with the highest
    prio - length(path)
is selected.

* To see what matches, add the -r option to see all results.
* The -q option shows the Query string that is used in a SQL-LIKE
* The Placeholders _ and % can be used


Priority
--------

A directorys priority is increased by 1 with every `cd`
it can also be change with `j -p` or `j -P`

More
----

See `j -h`

