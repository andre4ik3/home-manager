{ config, pkgs, lib }:

{
  options.programs.karabiner-elements = {
    enable = lib.mkEnableOption ''configuration of Karabiner-Elements.

      Note: this does not install Karabiner-Elements, to install it
      declaratively see `services.karabiner-elements.enable` in nix-darwin.
    '';
  };
}
