DOMAINPATH=/usr/freeware/bin:/usr/sbin:/usr/bsd

# CVS
export CVSROOT=/usr/local/cvs

PATH=/usr/freeware/pgsql/bin/:$PATH
MANPATH=$MANPATH:/usr/freeware/pgsql/man

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH-}:/usr/freeware/pgsql/lib
export PGLIB=$LD_LIBRARY_PATH 
export PGDATA=/usr/freeware/pgsql/data
 
