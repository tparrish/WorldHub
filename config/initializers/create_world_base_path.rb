World.base_path = Configuration.world.base_path
FileUtils.mkdir_p World.base_path
FileUtils.safe_unlink "public/world_assets"
FileUtils.ln_s World.base_path, "public/world_assets"