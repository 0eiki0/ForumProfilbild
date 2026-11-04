# frozen_string_literal: true

# name: discourse-minecraft-skin-avatar
# about: Schlägt Usern ihren Minecraft-Kopf (via mineskin.eu) als Profilbild vor
# version: 1.2.1
# authors: Marcel Eikmeier
# url: https://github.com/0eiki0/forumprofilbild
# required_version: 3.3.0

enabled_site_setting :minecraft_skin_avatar_enabled

register_asset "stylesheets/minecraft-skin-avatar.scss"

module ::MinecraftSkinAvatar
  PLUGIN_NAME = "discourse-minecraft-skin-avatar"
end

require_relative "lib/minecraft_skin_avatar/engine"

after_initialize do
  require_relative "lib/minecraft_skin_avatar/skin"
  require_relative "app/controllers/minecraft_skin_avatar/avatar_controller"

  # Liefert dem eingeloggten User den Vorschlag (oder nil) direkt mit aus
  add_to_serializer(:current_user, :minecraft_skin_suggestion) do
    MinecraftSkinAvatar.suggestion_for(object)
  end

  add_to_serializer(:current_user, :minecraft_skin_avatar) do
    MinecraftSkinAvatar.avatar_info_for(object)
  end
end
