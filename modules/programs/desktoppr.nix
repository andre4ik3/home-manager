{ config, pkgs, lib, ... }:

let
  cfg = config.programs.desktoppr;
in

{
  options.programs.desktoppr = {
    enable = lib.mkEnableOption "managing the desktop picture/wallpaper on macOS using desktoppr";
    package = lib.mkPackageOption pkgs "desktoppr" { };

    settings = {
      path = lib.mkOption {
        type = with lib.types; nullOr path;
        example = "/System/Library/Desktop Pictures/Solid Colors/Stone.png";
        description = ''
          The path to the desktop picture/wallpaper to set. Mutually exclusive
          with ``programs.desktoppr.settings.color``.
        '';
      };

      color = lib.mkOption {
        type = with lib.types; nullOr str; # TODO: regex color hex code
        default = null;
        example = "FF0000";
        description = ''
          The color to set as the desktop picture/wallpaper. Mutually exclusive
          with ``programs.desktoppr.settings.path``.
        '';
      };

      scale = lib.mkOption {
        type = lib.types.enum [ "fill" "stretch" "center" "fit" ];
        default = "fill";
        example = "fit";
        description = ''
          The scaling behavior to use when using an image.
        '';
      };

      setOnlyOnce = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          If false (the default), the desktop picture/wallpaper will be reset
          to the configured parameters on every system configuration change.

          If true, the desktop picture/wallpaper will only be set when it
          differs from the one previously set. This allows the user to manually
          change the desktop picture/wallpaper after it has been set.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.desktoppr" pkgs lib.platforms.darwin)
      {
        assertion = !(cfg.settings.path != null && cfg.settings.color != null);
        message = ''
          Only one of 'programs.desktoppr.settings.path' and
          'programs.desktoppr.settings.color' may be set.
        '';
      }
    ];

    targets.darwin.defaults.desktoppr = {
      picture = builtins.toString cfg.settings.path;
      inherit (cfg.settings) color scale setOnlyOnce;
    };

    home.activation.desktoppr = lib.hm.dag.entryAfter ["setDarwinDefaults"] ''
      verboseEcho "Setting the desktop picture/wallpaper"
      run ${lib.getExe cfg.package} manage
    '';
  };

  meta.maintainers = with lib.maintainers; [ andre4ik3 ];
}
