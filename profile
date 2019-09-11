# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "`id -u`" -eq 0 ]; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games"
fi
export PATH

if [ "${PS1-}" ]; then
  if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
secs=$((${upSeconds}%60))
mins=$((${upSeconds}/60%60))
hours=$((${upSeconds}/3600%24))
days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`
diskusage=$(df -H | grep -vE '^Filesystem|tmpfs|cdrom|mmcblk0p1' | awk '{ print $5 " " $1 }'| cut -f1 -d '%')
freemem=$(free -m  | grep ^Mem | tr -s ' ' | cut -d ' ' -f 4)
usedmem=$(free -m  | grep ^Mem | tr -s ' ' | cut -d ' ' -f 3)
swapusage=$(free -m  | grep ^Swap | tr -s ' ' | cut -d ' ' -f 3)

# get the load averages
read one five fifteen rest < /proc/loadavg

echo "$(tput setaf 2)

██████╗ ██╗██╗   ██╗██████╗ ███╗   ██╗               
██╔══██╗██║██║   ██║██╔══██╗████╗  ██║               
██████╔╝██║██║   ██║██████╔╝██╔██╗ ██║               
██╔═══╝ ██║╚██╗ ██╔╝██╔═══╝ ██║╚██╗██║               
██║     ██║ ╚████╔╝ ██║     ██║ ╚████║               
╚═╝     ╚═╝  ╚═══╝  ╚═╝     ╚═╝  ╚═══╝               
        //   ) )  // | |     / /     /__  ___/ 
       ((        //__| |    / /        / /     
         \\      / ___  |   / /        / /      
           ) ) //    | |  / /        / /       
    ((___ / / //     | | / /____/ / / /        
                                                         

   .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
  '. \ ' ' / .'   `uname -srmo`$(tput setaf 1)
   .~ .~~~..~.
  : .~.'~'.~. :   Uptime.............: ${UPTIME}
 ~ (   ) (   ) ~  RAM information....: ${freemem}M Free. ${usedmem}M used ${swapusage}M SWAP used
( : '~'.~.'~' : ) Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)
 ~ .~ (   ) ~. ~  Running Processes..: `ps ax | wc -l | tr -d " "`
  (  : '~' :  )   IP Addresses.......: `ip a | grep glo | awk '{print $2}' | head -1 | cut -f1 -d/` Public IP: `wget -q -O - http://icanhazip.com/ | tail`
   '~ .~~~. ~'    Weather............: `curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=EUR|UK|UK001|NAILSEA|" | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p'`
       '~'
$(tput sgr0)"

HISTSIZE=9000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignorespace:ignoredups

_bash_history_sync() {
  builtin history -a         #1
  HISTFILESIZE=$HISTSIZE     #2
  builtin history -c         #3
  builtin history -r         #4
}

history() {                  #5
  _bash_history_sync
  builtin history "$@"
}

PROMPT_COMMAND=_bash_history_sync
shopt -s histappend
chattr +a .bash_history
