# Configure Laptop Close Fix
if ! grep -q HandleLidSwitch=ignore /etc/systemd/logind.conf; then
    echo "* Applying laptop lid close fix"
    sudo bash -c 'echo HandleLidSwitch=ignore >> /etc/systemd/logind.conf'
    sudo systemctl restart systemd-logind
fi

# Install snap and microk8s and utilities
echo "* Installing snap, microk8s and enabling user access"
sudo apt update && sudo apt install snapd
sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER

# Enable useful extensions
echo "* Enabling microk8s extensions"
sudo microk8s enable dns dashboard rbac storage
