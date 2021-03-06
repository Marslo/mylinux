#!/bin/bash

# Script for installing tmux and dependencies.
# tmux will be installed in /usr/local/lib by default.

# Prerequisites: - gcc
#                - wget

# define versions
export LD_LIBRARY_PATH="$HOME/local/lib"
export LD_RUN_PATH="$HOME/local/lib"

tmux_version="2.0"
tmux_patch_version="a" # leave empty for stable releases

libevent_version="2.1.5-beta"
ncurses_version="6.0"

tmux_name="tmux-$tmux_version"
tmux_relative_url="$tmux_name/$tmux_name$tmux_patch_version"
libevent_name="libevent-$libevent_version-stable"
ncurses_name="ncurses-$ncurses_version"

# set the installation directory

target_dir="/usr/local"

# download source files for tmux, libevent, and ncurses
# save them in /tmp

cd /tmp

wget -O $tmux_name.tar.gz http://sourceforge.net/projects/tmux/files/tmux/$tmux_relative_url.tar.gz/download
wget -O ${libevent_name}.zip https://github.com/libevent/libevent/archive/master.zip
# wget -O $libevent_name.tar.gz https://github.com/downloads/libevent/libevent/$libevent_name.tar.gz
wget -O $ncurses_name.tar.gz ftp://ftp.gnu.org/gnu/ncurses/$ncurses_name.tar.gz

# extract files, configure, and compile

# libevent installation
# tar xvzf $libevent_name.tar.gz
unzip $libevent_name.zip
cd $libevent_name
./configure --prefix=$target_dir --disable-shared
make
make install
cd -

# ncurses installation
tar xvzf $ncurses_name.tar.gz
cd $ncurses_name
./configure --prefix=$target_dir
make
make install
cd -

# tmux installation
tar xvzf ${tmux_name}*.tar.gz
cd ${tmux_name}*/
./configure CFLAGS="-I$target_dir/include -I$target_dir/include/ncurses" LDFLAGS="-L$target_dir/lib -L$target_dir/include/ncurses -L$target_dir/include"
CPPFLAGS="-I$target_dir/include -I$target_dir/include/ncurses" LDFLAGS="-static -L$target_dir/include -L$target_dir/include/ncurses -L$target_dir/lib" make
make install
# cp tmux $target_dir/bin
cd -

version=`tmux -V | cut -d ' ' -f 2`
if [ -z "$version" ]; then
  echo
  echo "[error] failed to install tmux - check for errors in the above output"
  exit 1
fi
