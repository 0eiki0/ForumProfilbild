# frozen_string_literal: true

# Routen müssen in dieser Datei stehen: Discourse lädt die Routen beim Start
# neu, Routen die nur in plugin.rb gezeichnet werden gehen dabei verloren.
MinecraftSkinAvatar::Engine.routes.draw do
  post "/apply" => "avatar#apply"
  post "/dismiss" => "avatar#dismiss"
end

Discourse::Application.routes.draw do
  mount ::MinecraftSkinAvatar::Engine, at: "/minecraft-skin-avatar"
end
