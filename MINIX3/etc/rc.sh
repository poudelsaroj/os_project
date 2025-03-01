# /etc/rc - System startup script run by init before going multiuser.

exec >/dev/log
exec 2>/dev/log
exec </dev/null

umask 022
FSTAB=/etc/fstab
TERM="${TERM-minix}"
PATH=/usr/local/bin:/bin:/usr/bin:/usr/sbin:/usr/pkg/bin:/usr/pkg/sbin:/sbin
RC_TZ=/etc/rc.timezone
export TERM PATH

usage()
{
    echo >&2 "Usage: $0 [-saf] start|stop|down"
    exec intr sh
}

up()
{
    # Function to dynamically start a system service
    opt=""
    prefix=$(expr "$1 " : '\(-\)')
    if [ "$prefix" = "-" ];
    then
         opt=$1
         shift
    fi
    service=$1
    shift

    service $opt up /sbin/$service "$@"
}

edit()
{
    # Function to dynamically edit system service settings
    opt=""
    prefix=$(expr "$1 " : '\(-\)')
    if [ "$prefix" = "-" ];
    then
         opt=$1
         shift
    fi
    service=$1
    shift

    # Assume binaries are always in /usr/sbin
    service $opt edit /usr/sbin/$service -label $service "$@" 
}

# This function parses the deprecated minix shellscript-style 
# /etc/fstab, and fscks and mounts its filesystems.
mountfstab_poorman()
{
    echo "WARNING: old fstab format, please upgrade!"

    # /etc/fstab lists the root, home, and usr devices.
    . $FSTAB

    intr fsck.mfs $fsckopts $usr
    if [ ! -z "$home" ]
    then intr fsck.mfs $fsckopts $home
    fi

    # mount /usr
    mount $bin_img $usr /usr

    if [ ! -z "$home" ]
    then mount $bin_img $home /home || echo "WARNING: couldn't mount $home on /home"
    fi
}

while getopts 'saf' opt
do
    case $opt in
    s)	sflag=t ;;	# Single user
    a)	aflag=t ;;	# Ask for /usr
    f)	fflag=-f ;;	# Force a full file system check
    *)	usage
    esac
done
shift `expr $OPTIND - 1`

case "$#:$1" in
1:start|1:stop|1:down)
    action=$1
    ;;
*)  usage
esac

case $action in
start)

    # National keyboard?
    test -f /etc/keymap && loadkeys /etc/keymap

    # options for fsck. default is -r, which prompts the user for repairs.
    optname=fsckopts
    fsckopts=-p
    if sysenv $optname >/dev/null
    then       fsckopts="`sysenv $optname`"
    fi

    if [ "`sysenv debug_fkeys`" != 0 ]
    then
        up -n is -period 5HZ
    fi

    # Set timezone.
    export TZ=GMT0
    if [ -f "$RC_TZ" ]
    then . "$RC_TZ"
    fi

    # Try to read the hardware real-time clock, otherwise do it manually.
    readclock || intr date -q

    # Initialize files.
    >/etc/utmp				# /etc/utmp keeps track of logins

    # Use MFS binary only from kernel image?
    if [ "`sysenv bin_img`" = 1 ]
    then
        bin_img="-i "
    fi

    # Are we booting from CD?
    bootcd="`/bin/sysenv bootcd`"

    # If booting from CD, mounting is a special case.
    # We know what to do - only /usr is mounted and it's readonly.
    if [ "$bootcd" = 1 ]
    then	usrdev="$cddev"p2
    		echo "/usr on cd is $usrdev"
		mount -r $usrdev /usr
    else	
    # If we're not booting from CD, fsck + mount using /etc/fstab.
		read <$FSTAB fstabline
		if [ "$fstabline" = "# Poor man's File System Table." ]
		then	mountfstab_poorman	# Old minix /etc/fstab
		else	fsck -x / $fflag $fsckopts
			mount -a
		fi
    fi

    # Unmount and free now defunct ramdisk
    umount /dev/imgrd > /dev/null || echo "Failed to unmount boot ramdisk"
    ramdisk 0 /dev/imgrd || echo "Failed to free boot ramdisk"

    # Edit settings for boot system services
    if [ "`sysenv skip_boot_config`" != 1 ]
    then
	edit rs
	edit vm
	edit pm
	edit sched
	edit vfs
	edit ds
	edit tty
	edit memory
	edit -p log
	edit -c pfs
	edit init
    fi

    # This file is necessary for above 'shutdown -C' check.
    # (Silence stderr in case of running from cd.)
    touch /usr/adm/wtmp /etc/wtmp 2>/dev/null

    if [ "$sflag" ]
    then
	echo "Single user. Press ^D to resume multiuser startup."
	intr sh
	echo
    fi

    echo "Multiuser startup in progress ..."

    case "`printroot -r`":$bootcd in
    /dev/ram:)
	# Remove boot-only things to make space,
	# unless booting from CD, in which case we need them.
	rm -rf /boot
	# put the compiler on ram
	cp /usr/lib/em* /usr/lib/cpp* /lib
    esac

    echo -n "Starting hotplugging infrastructure... "
    rm -f /var/run/devmand.pid
    devmand -d /etc/devmand -d /usr/pkg/etc/devmand &
    echo "done."

    # Things should be alright now.
    ;;
down|stop)
    sync
    if [ -f /var/run/devmand.pid ]
    then
    	kill -INT `cat /var/run/devmand.pid`
        # without this delay the following will 
        # be printed in the console
        # RS: devman not running?
        sleep 1
    fi
    #
    # usbd needs to be stopped exactly 
    # at this stage(before stopping devman
    # and after stopping the services
    # stated by devmand)
    if [ -x /usr/pkg/etc/rc.d/usbd ]
    then 
    	/usr/pkg/etc/rc.d/usbd stop
    fi
    # Tell RS server we're going down.
    service shutdown
    ;;
esac

# Further initialization.
test -f /usr/etc/rc && sh /usr/etc/rc $action
test -f /usr/local/etc/rc && sh /usr/local/etc/rc $action

# Any messages?
test "$action" = start -a -f /etc/issue && cat /etc/issue

clear

echo "====================================================================="
echo "  ||      || ||||||||  ||     |||||||| ||||||||| |||||||||| ||||||| "
echo "  ||      || ||        ||     ||       ||     || ||  ||  || ||      "
echo "  ||      || ||||||    ||     ||       ||     || ||      || ||||    "
echo "  ||  ||  || ||        ||     ||       ||     || ||      || ||      "
echo "  |||||||||| ||||||||  |||||| |||||||| ||||||||| ||      || ||||||| "
echo "====================================================================="
echo " Welcome to MINIX 3!! Enjoy our customized MINIX!		"
echo "CHANGES MADE AS A PART OF OS LAB FOR EDUCATIONAL PURPOSE"
echo "============================================================"
echo "Note: This version of Minix is customized by Prabesh Bashyal, Pratik Adhikari,"
echo "Saroj Poudel and Spandan Bhandari as a part of our OS project."


exit 0