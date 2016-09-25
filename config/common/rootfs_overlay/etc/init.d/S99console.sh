# Set up the local console to display our banner and the system log,
# for use as last-ditch debugging facility on platforms that allow the
# user to get a screenshot of the local console.
cat >/dev/tty1 /usr/share/defgrid/prepare_console.txt
cat >/dev/tty1 /usr/share/defgrid/console_banner.txt
cat >/dev/tty1 /usr/share/defgrid/console_scroll_region.txt
nohup tail >/dev/tty1 -n20 /var/log/messages &
