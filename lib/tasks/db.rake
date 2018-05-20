task remove_rom_connection: [:environment] do
  ROM.env&.disconnect
end

Rake::Task['db:drop'].clear_prerequisites
Rake::Task['db:drop'].enhance [:remove_rom_connection, :load_config, :check_protected_environments]

Rake::Task['db:reset'].clear_prerequisites
Rake::Task['db:reset'].enhance [:remove_rom_connection, 'db:drop', 'db:setup']
