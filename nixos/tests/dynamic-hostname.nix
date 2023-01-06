{ system ? builtins.currentSystem
, config ? { }
, pkgs ? import ../.. { inherit system config; }
}:

with import ../lib/testing-python.nix { inherit system pkgs; };
with pkgs.lib;

makeTest {
  name = "dynamic-hostname";
  meta = {
    maintainers = with pkgs.lib.maintainers; [ trundle veehaitch ];
  };

  nodes.machine = { config, lib, ... }: {
    networking.hostName = "";

    systemd.services.set-hostname = {
      enable = true;
      description = "Dynamically set transient hostname";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "polkit.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "set-hostname.sh" ''
          ${pkgs.systemd}/bin/hostnamectl --transient hostname "wurzelpfropf"
        '';

        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0066";
        ProtectProc = "noaccess";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        RestrictAddressFamilies = [
          # Query hostname with curl
          "AF_INET"
          "AF_INET6"
          # DBus Socket
          "AF_UNIX"
        ];
        MemoryDenyWriteExecute = true;
        ProcSubset = "pid";
        LockPersonality = true;

        # Service explicitly sets the hostname
        # Needs network access
        PrivateNetwork = false;
        # Cannot be true due to Node

        User = "set-hostname";
        DynamicUser = true;
      };
    };

    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.hostname1.set-hostname"
              && subject.user == "${config.systemd.services.set-hostname.serviceConfig.User}") {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };

  testScript = { nodes, ... }: ''
    def get_aesmd_pid():
      status, main_pid = machine.systemctl("show --property MainPID --value aesmd.service")
      assert status == 0, "Could not get MainPID of aesmd.service"
      return main_pid.strip()

    with subtest("Wait for service"):
      machine.wait_for_unit("multi-user.target")

    print("systemctl status set-hostname")
    print(machine.systemctl("status set-hostname"))

    print("journalctl")
    print(machine.succeed("journalctl --no-pager -u set-hostname"))

    with subtest("Check hostname"):
      out = machine.succeed("${pkgs.systemd}/bin/hostnamectl status")
      print(out)
      assert "Transient hostname: wurzelpfropf" in out, "Hostname is not wurzelpfropf"
  '';
}
