# Laptop NixOS Setup (Framework 13)

## First-time install

### 1. Boot the NixOS installer

Download the NixOS ISO and create a bootable USB. Boot from it.

### 2. Connect to the network and sync the clock

WiFi (no ethernet expansion card):

```bash
sudo systemctl start wpa_supplicant
iwctl station wlan0 connect "<SSID>"
```

Or just plug in an ethernet expansion card.

The system clock is likely wrong, which will cause HTTPS certificate errors. Sync it before continuing:

```bash
sudo systemctl start systemd-timesyncd
timedatectl
```

Verify connectivity:

```bash
ping -c 1 nixos.org
```

### 3. Partition, encrypt, and mount disks

Partition manually for UEFI + LUKS full disk encryption:

```bash
# The Framework 13 has a single M.2 NVMe slot — the drive will be /dev/nvme0n1.
# Run `lsblk` to confirm before proceeding. Partitions will be:
#   /dev/nvme0n1p1 — EFI system partition (512MB, FAT32)
#   /dev/nvme0n1p2 — LUKS-encrypted root (rest of disk)
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 512MB 100%

# Format EFI partition
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1

# Set up LUKS encryption on root partition
sudo cryptsetup luksFormat /dev/nvme0n1p2
sudo cryptsetup open /dev/nvme0n1p2 cryptroot

# Format the unlocked LUKS volume
sudo mkfs.ext4 -L nixos /dev/mapper/cryptroot

# Mount
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

### 4. Generate hardware configuration

```bash
sudo nixos-generate-config --root /mnt
```

### 5. Clone the nix repo

```bash
nix-shell -p git
sudo mkdir -p /mnt/home/darko
sudo mkdir -p /mnt/home/darko/Documents/git
sudo git clone https://github.com/djanjic/nix /mnt/home/darko/Config
sudo chown -R 1000:users /mnt/home/darko
```

### 6. Copy hardware config into the repo

```bash
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/darko/Config/nix/system/framework/hardware-configuration.nix
```

### 7. Install NixOS

```bash
sudo nixos-install --root /mnt
```

### 8. Reboot and run update.sh

After rebooting into the new system:

```bash
cd ~/Config/nix
bash update.sh
```

The script uses `dmidecode` to detect the machine and automatically links the right config (`system/framework/` for the Framework 13). It will set up channels (including `nixos-hardware` for Framework-specific fixes), link config, rebuild the system, configure home-manager, and bootstrap LazyVim.

## Ongoing updates

Any time you change config files in this repo, re-run:

```bash
bash ~/Config/nix/update.sh
```

## Note on Framework 13 variant

[system/framework/configuration.nix](../system/framework/configuration.nix) imports `<nixos-hardware/framework/13-inch/amd-ai-300-series>` (AMD Ryzen AI 300 series). If you have a different model, update this line — available options include:
- `framework/13-inch/amd-ai-300-series`
- `framework/13-inch/7040-amd`
- `framework/13-inch/13th-gen`
- `framework/13-inch/12th-gen`
