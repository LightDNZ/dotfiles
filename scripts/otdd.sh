echo "Finding old udev rules..."
for c in /etc/udev/rules.d/9{0,9}-opentabletdriver.rules; do
  if [ -f "${c}" ]; then
    echo "Deleting ${c}"
    sudo rm "${c}"
  fi
done

echo "Finding old kernel module blacklist rules..."
if [ -f /etc/modprobe.d/blacklist.conf ]; then
  echo "Deleting /etc/modprobe.d/blacklist.conf"
  sudo rm /etc/modprobe.d/blacklist.conf
fi

sudo modprobe uinput
sudo rmmod wacom hid_uclogic > /dev/null 2>&1

sudo udevadm control --reload-rules && sudo udevadm trigger
