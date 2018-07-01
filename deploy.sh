#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

#/ Usage:
#/
#/    ELM_APP_YNAB_CLIENT_ID="client-id ELM_APP_YNAB_REDIRECT_URI=redirect-uri ./deploy.sh
#/
#/    ./deploy.sh --env-file .env.production
#/
#/ Description:
#/
#/     Send a production build of this application to GitHub for deployment.
#/
#/ Options:
#/     --env-file: Uses .env file to set required environment variables.
#/     --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }

# logging setup.
readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

redirect_uri=""
client_id=""
env_file=""

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      shift
      ;;
    --env-file)
      shift
      env_file=$1
      shift
      ;;
    *)
      echo "unrecognized flag ${1}. see --help for available options."
      exit 1
      ;;
  esac
done

export FOO=1

echo $FOO

if [[ -n $env_file ]]; then
  info "loading variables from ${env_file} ."
  source $env_file
fi

if [ -z $ELM_APP_YNAB_REDIRECT_URI ]; then
  fatal "please specify a ELM_APP_YNAB_REDIRECT_URI."
fi

if [ -z $ELM_APP_YNAB_CLIENT_ID ]; then
  fatal "please specify a ELM_APP_YNAB_CLIENT_ID."
fi

if [[ `git status --porcelain` ]]; then
  fatal "there are changes in your working directory. please commit or stash before continuing."
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

ELM_APP_YNAB_REDIRECT_URI=$ELM_APP_YNAB_REDIRECT_URI ELM_APP_YNAB_CLIENT_ID=$ELM_APP_YNAB_CLIENT_ID elm-app build

info "Committing Build Artifacts"

echo '!build/' >> '.gitignore'
git add .gitignore
git add build
git commit -m "build artifacts"

info "Deploying to GitHub"

git push origin $branch_name:deploy --force-with-lease

