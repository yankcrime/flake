{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
  
    settings = {
      add_newline = false;
      format = "$hostname$directory$vcsh$git_branch$git_commit$git_state$git_metrics$git_status$kubernetes$direnv$docker_context$package$buf$c$cmake$container$golang$helm$java$lua$nodejs$perl$pulumi$purescript$python$rlang$ruby$rust$swift$terraform$vagrant$nix_shell$conda$memory_usage$gcloud$openstack$azure$env_var$custom$sudo$cmd_duration$fill$time$line_break$jobs$battery$status$shell$character";
      
      hostname = {
        ssh_only = true;
        style = "";
        ssh_symbol = "";
      };
  
      fill.symbol = " ";
  
      c.style = "";
  
      character = {
        success_symbol = "[%](default)";
        vicmd_symbol = "[%](default)";
        error_symbol = "[%](bold red)";
      };
  
      git_branch = {
        style = "fg:dark_grey";
        symbol = " ";
      };
  
      git_status.style = "fg:dark_grey";
      git_state.style = "fg:dark_grey";
  
      git_metrics.added_style = "fg:dark_grey";
  
      directory = {
        style = "fg:dark_grey";
        truncation_symbol = "../";
      };
  
      jobs = {
        symbol = "·";
        style = "bold red";
      };
  
      time = {
        disabled = false;
        style = "";
        format = "[$time]($style) ";
      };

      nix_shell = {
        disabled = true;
        format = "via [❄️ $state( \($name\))](bold blue) ";
      };
  
      terraform.disabled = true;
      package.disabled = true;
      java.disabled = true;
      helm.disabled = true;
      
      golang = {
        disabled = true;
        style = "";
        format = "via [󰟓 ($version )]($style)";
      };
  
      kubernetes = {
        style = "";
        format = "[󱃾 ($context in) \\($namespace\\)]($style) ";
        disabled = false;
        contexts = [
          {
            context_pattern = "^teleport\\.glo1\\.nscale\\.com-(?P<cluster>[\\w-]+)$";
            context_alias = "$cluster";
          }
        ];
      };
  
      python = {
        disabled = false;
        format = "via [ ($version )]($style)(($virtualenv))";
        style = "fg:dark_grey";
        detect_extensions = [ ];
        detect_files = [
          ".python-version"
          "Pipfile"
          "__init__.py"
          "pyproject.toml"
          "requirements.txt"
          "setup.py"
          "tox.ini"
        ];
      };
  
      openstack = {
        style = "";
        format = "on [$cloud]($style) ";
      };
  
      docker_context = {
        disabled = true;
        style = "";
      };
  
      lua.disabled = true;
      nodejs.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;  
      direnv.disabled = false;
    };
  };
}
