# -*-ksh-*-

############################################################
# ALL amazon hosts

# Perforce & WS
export P4PORT=perforce:6791
export P4EDITOR=gnuclient
export MAXRESULTS=10000
alias ws=ws-dispatch
export AMAZON_PERFORCE_DEPOT=depot
export AMAZON_SHELF_DIR=/opt/build-shelf

if [ $HOSTNAME = "itsy" ]; then
  export P4CLIENT=ryand-itsy
else 
  export P4CLIENT=ryand-dec
fi

export QA_TEST_PORT=4007
export QA_TEST_HOST=qa-tools

export PRINTER=rainier
export CLASSPATH=

############################################################
# Non qa-tools amazon hosts

if [ $HOSTNAME != 'qa-tools' ]; then
#  DOMAINPATH=/opt/amazon/quality-assurance/bin:/opt/amazon/website/bin:/opt/amazon/bin:/opt/third-party/bin:/usr/local/gnu/bin:/usr/local/script:/dept/snoc/arch/bin:/usr/ccs/lib:/usr/ccs/bin

  DOMAINPATH=/opt/amazon/quality-assurance/bin:/opt/amazon/dev-services/bin:/opt/amazon/platform-services/bin
  
  # Backend Tools VARS
  export UNSAFE_CCMOTEL=true
  export AMAZON_ENVIRONMENT='test-us-hq'
  export AMAZON_REDIRECT_MAIL_TO=ryand@amazon.com
  
  # CVS
  export CVSROOT=/src/cvs

  export LD_LIBRARY_PATH=/dept/snoc/arch/lib:${LD_LIBRARY_PATH-}

  export INFOPATH=/opt/third-party/info:/usr/local/gnu/info/:${INFOPATH-}
  export MANPATH=/opt/third-party/man:/dept/snoc/man:${MANPATH-}
  
  export PERL5LIB=.:/toasters/toaster5/users/ryand/Dev/Perl

  # DEC UNIX has pitiful stack size limitations.
  ulimit -s $(ulimit -Hs)
fi
