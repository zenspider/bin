DOMAINPATH=/opt/amazon/quality-assurance/bin:/opt/amazon/website/bin:/opt/third-party/bin:/usr/local/gnu/bin:/usr/local/script:/usr/local/script/QA:/dept/snoc/arch/bin:/usr/ccs/lib:/usr/ccs/bin:/usr/ucb

# Allow use of tools against test db
export UNSAFE_CCMOTEL=true
export AMAZON_ENVIRONMENT='test-us-hq'

# Redierect all mail for some of the tools to me
export AMAZON_REDIRECT_MAIL_TO=ryand@amazon.com

# CVS
export CVSROOT=/src/cvs

export LD_LIBRARY_PATH=/dept/snoc/arch/lib:${LD_LIBRARY_PATH-}
export PRINTER=denali

MANPATH=/dept/snoc/man:${MANPATH-}

# DEC UNIX has pitiful stack size limitations.
ulimit -s $(ulimit -Hs)
