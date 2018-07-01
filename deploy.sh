#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage:
#/
#/    ./deploy.sh
#/
#/ Description:
#/
#/    Send a production build of this application to GitHub for deployment.
#/
#/ Options:
#/   --redirect-uri: URI to redirect users to after authentication. configured in YNAB.
#/   --client-id: YNAB API client id. retreived in YNAB.
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }

# logging setup.
readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

redirect_uri=""
client_id=""

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      shift
      ;;
    --client-id)
      shift
      client_id=$1
      shift
      ;;
    --redirect-uri)
      shift
      redirect_uri=$1
      shift
      ;;
    *)
      echo "unrecognized flag ${1}. see --help for available options."
      exit 1
      ;;
  esac
done


if [ -z $redirect_uri ]; then
  fatal "please specify a redirect uri."
fi

if [ -z $client_id ]; then
  fatal "please specify a client_id."
fi

# cleanup regardless of error.
cleanup() {
  git checkout -
}

trap cleanup EXIT

info "Checking out deployment branch"

time_of_deploy=$(date +"%Y-%m-%d_%H-%M-%S")
branch_name="deploy-${time_of_deploy}"
git checkout -b $branch_name

info "Building Elm App"

ELM_APP_YNAB_CLIENT_ID=$client_id ELM_APP_YNAB_REDIRECT_URI=$redirect_uri elm-app build

info "Committing Build Artifacts"

echo '!build/' >> '.gitignore'
git add .gitignore
git add build
git commit -m "build artifacts"

info "Deploying to GitHub"

git push origin $branch_name:deploy --force-with-lease

