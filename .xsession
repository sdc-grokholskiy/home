#!/bin/sh
echo "Executing ~/.xsession" 2>&1

if [ "$WINDOW_MANAGER" ]; then
	echo Warning: ~/.xsession overriding previous WINDOW_MANAGER="$WINDOW_MANAGER"
else
	export WINDOW_MANAGER=xmonad
fi

gnome-settings-daemon &
xsetroot -cursor_name left_ptr
# Lately in debian testing Gnome can't fucking do display settings. Wat. Try to
# set them up in a sane way.
case "`hostname`" in
	kino)
		# FIXME I'd like the left screen to be centered, but then my toolbars
		# are missing, on top of the virtual screen.
		xrandr \
			--output DP-4    --mode 1920x1080 --pos 0x0 --rotate normal --primary \
			--output HDMI-0  --mode 1680x1050 --rotate left --pos 1920x0
		;;
	yuki)
    randr.py
		;;
esac

# gnome doesn't have its fucking shit together with multiple-resolution
# displays. This command must always come after the xrandr command.
gsettings set org.gnome.desktop.interface text-scaling-factor '1.0'
# gnome is recently fucking up my keyboard settings
setxkbmap -model pc104 -layout us -option ctrl:nocaps
# gnome is doing an awesome new thing where it hides my fucking cursor
dconf write /org/gnome/settings-daemon/plugins/cursor/active false

case "`hostname`" in
	# only bash sets $HOSTNAME
	kino)
		;;
	yuki)
		# I don't know why, but key repeat is disabled by default for some keys
		# on my Fujitsu u904 laptop.
		xset r 113 r on
		xset r 116 r on
		;;
esac
stalonetray &
pasystray &
nm-applet &
$BROWSER &
# if i'm at work, throw away half my ram
if [ "$USER" = "mlamb" ]; then
    slack &
fi
if [ -f "$HOME/.vagrant.d/insecure_private_key" ]; then
	ssh-add $HOME/.vagrant.d/insecure_private_key
fi

# A notification daemon, at least until I find something better. Good to get
# this up after xchat to avoid the blast of notifications. Need a utility for
# viewing past notifications.
for f in notification-daemon notify-osd
do
	if [ -x /usr/lib/"$f"/"$f" ]; then
		/usr/lib/"$f"/"$f" &
		break
	fi
done

if which feh && [ -e $HOME/.wallpaper ]; then
	feh --bg-fill --no-xinerama $HOME/.wallpaper &
fi

seikotunnel sleep 300 &

if [ "$WINDOW_MANAGER" ]; then
	exec "$WINDOW_MANAGER"
else
	xmessage -timeout 5 "Window manager specified in .xsession not found." &
	exec xterm
fi
