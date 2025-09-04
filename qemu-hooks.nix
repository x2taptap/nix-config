{ config, pkgs, ... }:

{
systemd.services.libvirtd.preStart = let
    qemuHook = pkgs.writeScript "qemu-hook" ''
      #!/bin/sh

      GUEST_NAME="$1"
      OPERATION="$2"
      SUB_OPERATION="$3"

      if [ "$GUEST_NAME" == "win11" ]; then
        if [ "$OPERATION" == "prepare" ]; then
            echo "Stoping Display Manager"
            systemctl stop display-manager
            echo "Removing Virtual Consoles [+]"
            echo 0 > /sys/class/vtconsole/vtcon*/bind
            sleep "1"
            echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
            ## Unload NVIDIA GPU drivers ##
            echo "modprobe -r nvidia [+]"
            modprobe -r nvidia_uvm
            modprobe -r nvidia_drm
            modprobe -r nvidia_modeset
            modprobe -r nvidia
            modprobe -r i2c_nvidia_gpu
            modprobe -r drm_kms_helper
            modprobe -r drm
            echo "modprobe vfio [+]"
            modprobe vfio
            modprobe vfio_pci
            modprobe vfio_iommu_type1
        fi

        if [ "$OPERATION" == "release" ]; then
            echo "modprobe -r vfio [+]"
            modprobe -r vfio_pci
            modprobe -r vfio_iommu_type1
            modprobe -r vfio
            echo "modprobe Nvidia [+]"
            modprobe drm
            modprobe drm_kms_helper
            modprobe i2c_nvidia_gpu
            modprobe nvidia
            modprobe nvidia_modeset
            modprobe nvidia_drm
            modprobe nvidia_uvm
            echo "Starting Display Manager"
            systemctl start display-manager
            echo "Binding Virtual Consoles [+]"
            echo 1 > /sys/class/vtconsole/vtcon*/bind
        fi
      fi
    '';
  in ''
    mkdir -p /var/lib/libvirt/hooks
    chmod 755 /var/lib/libvirt/hooks

    # Copy hook files
    ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
  '';

}