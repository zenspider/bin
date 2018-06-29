# -*-ksh-*-

export CLASSPATH=
export HOMEBREW_GITHUB_API_TOKEN=$(git config github.oauth-token)
