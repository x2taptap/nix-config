{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia-drivers.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  boot.initrd.luks.devices."luks-b6ddb8f1-f96e-49da-8988-9993df8f25fa".device = "/dev/disk/by-uuid/b6ddb8f1-f96e-49da-8988-9993df8f25fa";
  networking.hostName = "yuri"; # Define your hostname.
  networking.extraHosts = ''
  10.10.10.2 mainframe
  '';
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
  boot = {
    kernelModules = [ "kvm-intel" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    kernelParams = [ "pcie_acs_override=downstream" "intel_iommu=on" "intel_iommu=pt" "kvm.ignore_msrs=1" ];
  };
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "user" "podman"];
    packages = with pkgs; [
      kdePackages.kate
      
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "user";



  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/user/Sources/nix-config";
  };


  
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    librewolf-bin
    pciutils
    gparted
    gnome-disk-utility
    gh
    unrar
    fastfetch
    vscode
    vesktop
    telegram-desktop
    easyeffects
    pavucontrol
    mangohud
    lutris
    cage
    lm_sensors
    protonup
    vmware-workstation
    distrobox
    lsfg-vk
    prismlauncher
    obs-studio
    vlc
    rpcs3
    uxplay
    linuxKernel.packages.linux_zen.xpadneo
    # Beamng Native Fix
    (pkgs.steam.override {
    extraLibraries = pkgs: [pkgs.fontconfig pkgs.nss];
    }).run
  ];
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  }; 

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.ubuntu-mono
    corefonts
    vista-fonts
 ];
  environment.variables = {
    LANG = "en_US.UTF-8";
    KWIN_DRM_DEVICES = "/dev/dri/by-driver/nvidia-card:/dev/dri/by-driver/intel-card";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/user/Documents/Other/Proton";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable Avahi
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # printing
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };
  # i dont have a time to set firewall
  networking.firewall.enable = lib.mkForce false;
  system.stateVersion = "25.11"; 
  # Clean Garbage
  nix.settings.auto-optimise-store = true;


  hardware.display.edid.packages = [
    (pkgs.runCommand "edid-custom" { } ''
      mkdir -p $out/lib/firmware/edid
      base64 -d > "$out/lib/firmware/edid/custom1.bin" <<'EOF'
      AP///////wAGELWcAAAAABwTAQSlPCJ4Im+xp1VMniUMUFQAAAABAQEBAQEBAQEBAQEBAQEBNGgAoKCgLlAwIDUAALAxAAACGh0AgFHQHCBAgDUAVVAhAAAcAAAAAAAAAAAAAAAAAAAAAAAAAAAA/ABDb2xvciBMQ0QKICAgAT0CAwzBIwkHB4MBAABWXgCgoKApUDAgNQBVUCEAABoaHQCAUdAcIECANQBVUCEAABwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEw==
      EOF
    '')
  ];
  hardware.display.outputs."DP-1".edid = "custom1.bin";
  services.udev.extraRules = ''
    KERNEL=="card*", DRIVERS=="i915", SYMLINK+="dri/by-driver/intel-card"
    KERNEL=="card*", DRIVERS=="nvidia", SYMLINK+="dri/by-driver/nvidia-card"
  '';


  # Virtualization
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["user"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.vmware.host.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
