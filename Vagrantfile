Vagrant.configure("2") do |config|
    config.vm.box = "bento/amazonlinux-2"
    config.vm.provision "file", source: "factorio.service", destination: "/tmp/factorio.service"
    config.vm.provision "file", source: "factorio_run.sh", destination: "/tmp/factorio_run.sh"
    config.vm.provision "file", source: "backup-on-change.service", destination: "/tmp/backup-on-change.service"
    config.vm.provision "file", source: "backup_save_on_change.sh", destination: "/tmp/backup_save_on_change.sh"
    config.vm.provision "file", source: "vagrant_scripts/load_settings.sh", destination: "/tmp/load_settings.sh"
    config.vm.provision "file", source: "server_config/server-settings.json", destination: "/tmp/server-settings.json"
    config.vm.provision "file", source: "server_config/server-adminlist.json", destination: "/tmp/server-adminlist.json"
    config.vm.provision "file", source: "server_config/map-gen-settings.json", destination: "/tmp/map-gen-settings.json"
    config.vm.provision "file", source: "server_config/map-settings.json", destination: "/tmp/map-settings.json"
    config.vm.provision "shell", path: "vagrant_scripts/init.sh"
    config.vm.provision "shell", path: "vagrant_scripts/backups_retain_config.sh", args: ["5"]
    config.vm.provision "shell", path: "install_extras.sh"
    config.vm.provision "shell", path: "copy_to_priv.sh"
    config.vm.provision "shell", path: "factorio_install.sh", args: [ENV['VERSION']]
    config.vm.provision "shell", path: "vagrant_scripts/make_saves_dir.sh"
    config.vm.network "forwarded_port", guest: 34197, host: 34197, protocol: "udp"
end
