{ pkgs, lib, config, ... }:

{
  options = {
    # This creates the enable toggle, just like your vscode-module
    ai-module.enable = lib.mkEnableOption "Enables Ollama, Open-WebUI, and AI start scripts";
  };

  config = lib.mkIf config.ai-module.enable {

    users.users.lexyoai.home = lib.mkForce "/home/lexyoai";
    
    # 1. Configure Ollama with the custom save location
    services.ollama = {
      enable = true;
      user = "lexyoai";
      group = "users";
      environmentVariables = {
        OLLAMA_MODELS = "/home/lexyoai/AI_Models";
      };
    };

    # 2. Configure the Web UI 
    services.open-webui = {
      enable = true;
      environment = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      };
    };

    # 3. Stop them from running automatically on boot (Saves your 16GB of RAM)
    systemd.services.ollama.wantedBy = lib.mkForce [];
    systemd.services.open-webui.wantedBy = lib.mkForce [];

    # 4. Create the automation scripts
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "ai-start" ''
        echo "Checking if AI services are running..."
        
        # Check if Ollama is running. If not, start both.
        if ! systemctl is-active --quiet ollama; then
          echo "Starting Ollama and Open-WebUI (may prompt for sudo password)..."
          sudo systemctl start ollama open-webui
        else
          echo "AI services are already running."
        fi
        
        echo "Opening Web UI..."
        sleep 2 # Give the web server a second to spin up
        
        # Open the default web browser to the UI
        ${pkgs.xdg-utils}/bin/xdg-open http://localhost:8080
      '')

      # I added an extra script so you can easily turn them off when you're done!
      (writeShellScriptBin "ai-stop" ''
        echo "Shutting down AI services to free up RAM..."
        sudo systemctl stop ollama open-webui
        echo "AI offline."
      '')
    ];

    # Ensure the model directory exists with the correct permissions.
    # Note: Because Ollama runs as a system service, we use systemd-tmpfiles 
    # to guarantee the folder exists before Ollama tries to write to it.
    systemd.tmpfiles.rules = [
      "d /home/lexyoai/AI_Models 0755 lexyoai users -"
    ];
  };
}