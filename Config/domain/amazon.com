# -*-ksh-*-

if [ $HOSTNAME != 'qa-tools' ]; then
  DOMAINPATH=/opt/amazon/quality-assurance/bin:/opt/amazon/website/bin:/opt/third-party/bin:/usr/local/gnu/bin:/usr/local/script:/dept/snoc/arch/bin:/usr/ccs/lib:/usr/ccs/bin
  
  # Backend Tools VARS
  export UNSAFE_CCMOTEL=true
  export AMAZON_ENVIRONMENT='test-us-hq'
  export AMAZON_REDIRECT_MAIL_TO=ryand@amazon.com
  
  # CVS
  export CVSROOT=/src/cvs
  
  export LD_LIBRARY_PATH=/dept/snoc/arch/lib:${LD_LIBRARY_PATH-}
  export PRINTER=bianchi

  export INFOPATH=/opt/third-party/info:/usr/local/gnu/info/:${INFOPATH-}
  export MANPATH=/opt/third-party/man:/dept/snoc/man:${MANPATH-}
  
  export PERL5LIB=.:/toasters/toaster5/users/ryand/Dev/Perl

  # DEC UNIX has pitiful stack size limitations.
  ulimit -s $(ulimit -Hs)
fi

