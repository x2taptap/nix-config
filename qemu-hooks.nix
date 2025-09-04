{ config, pkgs, ... }:

{
  virtualisation.libvirtd.hooks.qemu = {
    "vfio-startup" = pkgs.writeShellScript "vfio-startup.sh" ''
      #!/bin/sh
      # Skrypt vfio-startup na podstawie https://gitlab.com/risingprismtv/single-gpu-passthrough/-/raw/master/hooks/vfio-startup
      set -x

      # Dodaje aktualny czas do logów
      DATE=$(date +"%m/%d/%Y %R:%S :")
      echo "$DATE Beginning of Startup!" >> /var/log/vfio-hook.log

      # Funkcja do zatrzymania menedżera wyświetlania
      stop_display_manager_if_running() {
          if [[ -x /run/systemd/system ]]; then
              echo "$DATE Distro is using Systemd" >> /var/log/vfio-hook.log
              DISPMGR="$(grep 'ExecStart=' /etc/systemd/system/display-manager.service | awk -F'/' '{print $(NF-0)}')"
              echo "$DATE Display Manager = $DISPMGR" >> /var/log/vfio-hook.log

              if systemctl is-active --quiet "$DISPMGR.service"; then
                  grep -qsF "$DISPMGR" "/tmp/vfio-store-display-manager" || echo "$DISPMGR" >/tmp/vfio-store-display-manager
                  systemctl stop "$DISPMGR.service"
                  systemctl isolate multi-user.target
              fi

              while systemctl is-active --quiet "$DISPMGR.service"; do
                  sleep 1
              done
              return
          fi
      }

      # Funkcja dla KDE
      kde_clause() {
          echo "$DATE Display Manager = display-manager" >> /var/log/vfio-hook.log
          if systemctl is-active --quiet "display-manager.service"; then
              grep -qsF "display-manager" "/tmp/vfio-store-display-manager" || echo "display-manager" >/tmp/vfio-store-display-manager
              systemctl stop "display-manager.service"
          fi
          while systemctl is-active --quiet "display-manager.service"; do
              sleep 2
          done
          return
      }

      # Sprawdzenie, czy używany jest KDE
      if pgrep -l "plasma" | grep "plasmashell"; then
          echo "$DATE Display Manager is KDE, running KDE clause!" >> /var/log/vfio-hook.log
          kde_clause
      else
          echo "$DATE Display Manager is not KDE!" >> /var/log/vfio-hook.log
          stop_display_manager_if_running
      fi

      # Usuń flagi NVIDIA/AMD
      if test -e "/tmp/vfio-is-nvidia"; then
          rm -f /tmp/vfio-is-nvidia
      else
          test -e "/tmp/vfio-is-amd"
          rm -f /tmp/vfio-is-amd
      fi

      sleep 1

      # Odwiązanie VTconsoles
      if test -e "/tmp/vfio-bound-consoles"; then
          rm -f /tmp/vfio-bound-consoles
      fi
      for (( i = 0; i < 16; i++)); do
          if test -x /sys/class/vtconsole/vtcon"$i"; then
              if [ "$(grep -c "frame buffer" /sys/class/vtconsole/vtcon"$i"/name)" = 1 ]; then
                  echo 0 > /sys/class/vtconsole/vtcon"$i"/bind
                  echo "$DATE Unbinding Console $i" >> /var/log/vfio-hook.log
                  echo "$i" >> /tmp/vfio-bound-consoles
              fi
          fi
      done

      sleep 1

      # Obsługa GPU NVIDIA
      if lspci -nn | grep -e VGA | grep -s NVIDIA; then
          echo "$DATE System has an NVIDIA GPU" >> /var/log/vfio-hook.log
          grep -qsF "true" "/tmp/vfio-is-nvidia" || echo "true" >/tmp/vfio-is-nvidia
          echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

          modprobe -r nvidia_uvm
          modprobe -r nvidia_drm
          modprobe -r nvidia_modeset
          modprobe -r nvidia
          modprobe -r i2c_nvidia_gpu
          modprobe -r drm_kms_helper
          modprobe -r drm
          echo "$DATE NVIDIA GPU Drivers Unloaded" >> /var/log/vfio-hook.log
      fi

      # Obsługa GPU AMD
      if lspci -nn | grep -e VGA | grep -s AMD; then
          echo "$DATE System has an AMD GPU" >> /var/log/vfio-hook.log
          grep -qsF "true" "/tmp/vfio-is-amd" || echo "true" >/tmp/vfio-is-amd
          echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

          modprobe -r drm_kms_helper
          modprobe -r amdgpu
          modprobe -r radeon
          modprobe -r drm
          echo "$DATE AMD GPU Drivers Unloaded" >> /var/log/vfio-hook.log
      fi

      # Wczytaj moduły VFIO
      modprobe vfio
      modprobe vfio_pci
      modprobe vfio_iommu_type1
      echo "$DATE End of Startup!" >> /var/log/vfio-hook.log
    '';

    "vfio-teardown" = pkgs.writeShellScript "vfio-teardown.sh" ''
      #!/bin/sh
      # Skrypt vfio-teardown na podstawie https://gitlab.com/risingprismtv/single-gpu-passthrough/-/raw/master/hooks/vfio-teardown
      set -x

      # Dodaje aktualny czas do logów
      DATE=$(date +"%m/%d/%Y %R:%S :")
      echo "$DATE Beginning of Teardown!" >> /var/log/vfio-hook.log

      # Usuń moduły VFIO
      modprobe -r vfio_pci
      modprobe -r vfio_iommu_type1
      modprobe -r vfio
      echo "$DATE VFIO Drivers Unloaded" >> /var/log/vfio-hook.log

      # Wczytaj sterowniki NVIDIA
      if test -e "/tmp/vfio-is-nvidia"; then
          modprobe drm
          modprobe drm_kms_helper
          modprobe i2c_nvidia_gpu
          modprobe nvidia
          modprobe nvidia_modeset
          modprobe nvidia_drm
          modprobe nvidia_uvm
          echo "$DATE NVIDIA Drivers Loaded" >> /var/log/vfio-hook.log
      fi

      # Wczytaj sterowniki AMD
      if test -e "/tmp/vfio-is-amd"; then
          modprobe drm
          modprobe drm_kms_helper
          modprobe amdgpu
          echo "$DATE AMD Drivers Loaded" >> /var/log/vfio-hook.log
      fi

      # Przywróć EFI-Framebuffer
      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind
      echo "$DATE Restored EFI-Framebuffer" >> /var/log/vfio-hook.log

      # Przywróć VTconsoles
      if test -e "/tmp/vfio-bound-consoles"; then
          while read -r i; do
              echo 1 > /sys/class/vtconsole/vtcon"$i"/bind
              echo "$DATE Rebinding Console $i" >> /var/log/vfio-hook.log
          done < /tmp/vfio-bound-consoles
          rm -f /tmp/vfio-bound-consoles
      fi

      # Przywróć menedżer wyświetlania
      if test -e "/tmp/vfio-store-display-manager"; then
          systemctl start "$(cat /tmp/vfio-store-display-manager)".service
          echo "$DATE Display Manager $(cat /tmp/vfio-store-display-manager) Restarted" >> /var/log/vfio-hook.log
          rm -f /tmp/vfio-store-display-manager
      fi

      echo "$DATE End of Teardown!" >> /var/log/vfio-hook.log
    '';
  };

}