#!/bin/bash
# shellcheck disable=SC1078,SC1079,SC2086
# =============================================================================
#    FileName : ifunc.sh
#      Author : marslo.jiao@gmail.com
#     Created : 2012
#  LastChange : 2021-01-15 22:00:55
# =============================================================================

function take()
{
  mkdir -p "$1" && cd "$1" || return
}

function cdls()
{
  cd "$1" && ls
}

function cdla()
{
  cd "$1" && la
}

function chmv()
{
  sudo mv "$1" "$2"
  sudo chown -R "$(whoami)":"$(whoami)" "$2"
}

function chcp()
{
  sudo cp -r "$1" "$2"
  sudo chown -R "$(whoami)":"$(whoami)" "$2"
}

function cha()
{
  sudo chown -R "$(whoami)":"$(whoami)" "$1"
}

# Inspired from http://www.earthinfo.org/linux-disk-usage-sorted-by-size-and-human-readable/
function udfs {
  v='*'
  # shellcheck disable=SC2124
  [ 1 -le $# ] && v="$@"
  du -sk ${v} | sort -nr | while read -r size fname;
  do
    for unit in k M G T P E Z Y;
    do
      if [ "$size" -lt 1024 ];
      then
        echo -e "${size}${unit}\\t${fname}";
        break;
      fi;
      size=$((size/1024));
    done;
  done
}

function mydiff() {
  echo -e " [${1##*/}]\\t\\t\\t\\t\\t\\t\\t[${2##*/}]"
  diff -y --suppress-common-lines "$1" "$2"
}

function dir()
{
  find . -iname "$@" -print0 | xargs -r0 ${LS} -altr | awk '{print; total += $5}; END {print "total size: ", total}';
}

function dir-h()
{
  find . -iname "$@" -exec ${LS} -lthrNF --color=always {} \;
  find . -iname "$@" -print0 | xargs -r0 du -csh| tail -n 1
}

function rcsync()
{
  SITE="Jira Confluence Jenkins Gitlab Artifactory Sonar Slave"
  HNAME=$( hostname | tr '[:upper:]' '[:lower:]' )
  for i in $SITE; do
    CURNAME=$( echo "$i" | tr '[:upper:]' '[:lower:]' )
    if [ "$HNAME" != "$CURNAME" ]; then
      echo ------------------- "$i" ---------------------;
      pushd "$PWD"
      cd "/home/appadmin"
      rsync \
        -avzrlpgoD \
        --exclude=Tools \
        --exclude=.vim/view \
        --exclude=.vim/vimsrc \
        --exclude=.vim/cache \
        --exclude=.vim/.netrwhist \
        --exclude=.ssh/known_hosts \
        -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ' \
        .marslo .vim .vimrc .inputrc .tmux.conf .pip appadmin@"$i":~/
      popd
    fi
  done
}

function getperm()
{
  find "$1" -printf '%m\t%u\t%g\t%p\n'
}

function rdiff()
{
  rsync -rv --size-only --dry-run "$1" "$2"
}

function proxydefault() {
  myssproxy="socks5://127.0.0.1:1880"
  myppproxy="http://127.0.0.1:8123"

  socks_proxy=${myssproxy}
  SOCKS_PROXY=${myssproxy}

  all_proxy=${myppproxy}
  ALL_PROXY=${myppproxy}

  http_proxy=${myppproxy}
  HTTP_PROXY=${myppproxy}
  https_proxy=${myppproxy}
  HTTPS_PROXY=${myppproxy}
  ftp_proxy=${myppproxy}
  FTP_PROXY=${myppproxy}

  # kubeIP=""
  flannelIP="$(echo 10.244.0.{0..255} | sed 's: :,:g')"
  privIP=$(echo 192.168.10.{0..255} | sed 's: :,:g')
  compDomain=".cdi.philips.com,.philips.com,pww.*.cdi.philips.com,pww.artifactory.cdi.philips.com,healthyliving.cn-132.lan.philips.com,*.cn-132.lan.philips.com,pww.sonar.cdi.philips.com,pww.gitlab.cdi.philips.com,pww.slave01.cdi.philips.com,pww.confluence.cdi.philips.com,pww.jira.cdi.philips.com,bdhub.pic.philips.com,tfsemea1.ta.philips.com,pww.jenkins.cdi.philips.com,blackduck.philips.com,fortify.philips.com"
  no_proxy="localhost,127.0.0.1,127.0.1.1,130.147.182.57,192.168.10.235,172.17.0.1,10.244.0.0,10.244.0.1,${compDomain},${flannelIP},${privIP}"
  NO_PROXY=$no_proxy

  export socks_proxy SOCKS_PROXY all_proxy ALL_PROXY
  export http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy FTP_PROXY
  export no_proxy NO_PROXY
}

function rget(){
  route -nv get "$@"
}

function forget() {
  history -d $(( $(history | tail -n 1 | ${GREP} -oP '^ \d+') - 1 ));
}

function dir755() {
  find . -type d -perm 0777 \( -not -path "*.git" -a -not -path "*.git/*" \) -exec sudo chmod 755 {} \; -print
}

function file644() {
  find . -type f -perm 0777 \( -not -path "*.git" -a -not -path "*.git/*" \) -exec sudo chmod 644 {} \; -print
}

function convert2av() {
  ffmpeg -i "$1" -i "$2" -c copy -map 0:0 -map 1:0 -shortest -strict -2 "$3"
}

function zh() {
  zipinfo "$1" | head
}

function 256color() {
  for i in {0..255}; do
    echo -e "\e[38;05;${i}m█${i}";
  done | column -c 180 -s ' '; echo -e "\e[m"
}

# how may days == ddiff YYYY-MM-DD now
hmdays() {
  usage="""SYNOPSIS
  \n\t\$ hmdays YYYY-MM-DD
  \nEXAMPLE
  \n\t\$ hmdays 1987-03-08
  """

  if [ 1 -ne $# ]; then
    echo -e "${usage}"
  else
    if date +%s --date "$1" > /dev/null 2>&1; then
      echo $((($(date +%s)-$(date +%s --date "$1"))/(3600*24))) days
    else
      echo -e "${usage}"
    fi
  fi
}

ibtoc() {
  find "${MYWORKSPACE}/tools/git/marslo/mbook/docs" \
       -iname '*.md' \
       -not -path '**/SUMMARY.md' \
       -exec doctoc --github --maxlevel 3 {} \;
}

gtoc() {
  top=$(git rev-parse --show-toplevel)
  if [ 1 -eq $# ]; then
    case $1 in
      [mM] )
        top="${top}/docs"
        ;;
    esac
  fi

  find ${top} \
       -iname '*.md' \
       -not -path '**/SUMMARY.md' \
       -exec doctoc --github --maxlevel 3 {} \;
}

function cleanview(){
  rm -rf ~/.vim/view/*
}

# vim: ts=2 sts=2 sw=2 et ft=sh
