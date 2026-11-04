# frozen_string_literal: true

module ::MinecraftSkinAvatar
  class AvatarController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    requires_login

    def apply
      RateLimiter.new(current_user, "minecraft-skin-apply", 5, 1.minute).performed!

      variant = params[:variant].presence || MinecraftSkinAvatar::DEFAULT_VARIANT
      raise Discourse::InvalidParameters.new(:variant) if MinecraftSkinAvatar::VARIANTS.exclude?(variant)

      name = MinecraftSkinAvatar.minecraft_name_for(current_user)
      if name.blank?
        return render_json_error(I18n.t("minecraft_skin_avatar.errors.no_name"), status: 422)
      end

      upload = MinecraftSkinAvatar.download_and_create_upload(current_user, name, variant)
      if upload.nil? || !upload.persisted?
        return(
          render_json_error(I18n.t("minecraft_skin_avatar.errors.download_failed"), status: 422)
        )
      end

      MinecraftSkinAvatar.set_avatar!(current_user, upload, name, variant)

      render json: success_json.merge(avatar_template: current_user.reload.avatar_template)
    end

    def dismiss
      name = MinecraftSkinAvatar.minecraft_name_for(current_user)
      current_user.custom_fields[MinecraftSkinAvatar::DISMISSED_FIELD] = name.to_s
      current_user.save_custom_fields(true)
      render json: success_json
    end
  end
end
