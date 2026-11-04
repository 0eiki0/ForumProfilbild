# frozen_string_literal: true

module ::MinecraftSkinAvatar
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace MinecraftSkinAvatar
  end
end
