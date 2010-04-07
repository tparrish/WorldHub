FileUtils.mkdir_p Configuration.world.base_path
FileUtils.safe_unlink "public/world_assets"
FileUtils.ln_s Configuration.world.base_path, "public/world_assets"