Bash Jump
=========

Type `j moz fire /` instead of `cd ~/.mozilla/firefox/asdfgh.default/` or `j htt conf` instead of `cd /etc/httpd/conf/`
just like <https://github.com/joelthelion/autojump> but all bash.


Setup
-------

Install `sqlite3` and clone this repo or download the `jump.bash` file. Then
put something like the following into your bashrc:

    BASHJUMP_HISTORY=~/.config/jumphistory.sqlite
    source ~/code/bashjump/jump.bash
    alias cd=bashjump_cd
    alias j=bashjump_jump

Open a new bash in execute:

    bashjump_check_or_create_db

After that, `cd` will behav exactly the same way, but record directories you visit,
`j` will be the Jump command.

Use
---

Every directory you go to with `cd` will be added to the database, or its priority increased.
Later you can use `j pattern` to change to a previously recorded directory that matches the pattern.


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
* `j b` the last
* `j src` the last  (higest Priority)
* `j a` the first (parent of all other matches)
* `j a src` the second
* `j a / /` the third

Special Parameters:
* A single dot `.` will prepend the current directory to the query
* To see what matches instead of jumping, add the `-r` option
* The `-q` option shows the Query string that is used in a SQL-LIKE
* The Placeholders `_` and `%` can be used

Priority
--------

A directorys priority is increased by 1 with every `cd`
and can also be change with `j -p` or `j -P`.

More
----

See `j -h`

