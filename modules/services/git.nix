{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.git;

in {
  meta.maintainers = [];

  options.services.git = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "TODO";
    };

    repositories = mkOption {
      type = types.attrsOf (types.submodule ({config, name, ...}: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            example = "TODO";
            description = "TODO";
          };

          url = mkOption {
            type = types.str;
            example = "TODO";
            description = "TODO";
          };
        };
      }));
      default = {};
      example = "TODO";
      description = "TODO";
    };
  };

  config = mkIf cfg.enable {
    assertions = [];

    systemd.user.services = flip mapAttrs' cfg.repositories (name: repository: let
        uname = stringAsChars
          (c: if builtins.match "[a-zA-Z]" c != null then c else "-")
          name;
      in nameValuePair "git-repository-${uname}" {
        Unit = { Description = "TODO"; };
        Service = {
          ExecStart = toString
            (pkgs.writeShellScript
              "ensure-git-repository-${uname}"
              ''
                set -ex
                if [[ ! -d "${name}" ]]; then
                  ${pkgs.git}/bin/git clone '${repository.url}' "${name}"
                fi
                exit 0
              ''
            );
          Restart = "on-failure";
          RestartSec = 180;
        };
      }
    );
  };

}
