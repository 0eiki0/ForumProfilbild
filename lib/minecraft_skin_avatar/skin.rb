# frozen_string_literal: true

module ::MinecraftSkinAvatar
  # Gültige Minecraft (Java) Namen: Buchstaben, Ziffern, Unterstrich, max. 16 Zeichen
  NAME_REGEX = /\A[A-Za-z0-9_]{1,16}\z/

  DISMISSED_FIELD = "minecraft_skin_dismissed_for"
  APPLIED_FIELD = "minecraft_skin_applied_for"
  APPLIED_UPLOAD_FIELD = "minecraft_skin_applied_upload_id"

  def self.user_field
    name = SiteSetting.minecraft_skin_avatar_user_field.to_s.strip
    return nil if name.blank?
    UserField.find_by("LOWER(name) = ?", name.downcase)
  end

  def self.minecraft_name_for(user)
    field = user_field
    return nil unless field && user

    value = user.custom_fields["user_field_#{field.id}"].to_s.strip
    NAME_REGEX.match?(value) ? value : nil
  end

  def self.skin_url(name)
    SiteSetting.minecraft_skin_avatar_url_template.gsub("{name}", CGI.escape(name))
  end

  # Gibt { name:, url: } zurück, wenn dem User der Skin vorgeschlagen werden soll
  def self.suggestion_for(user)
    return nil unless SiteSetting.minecraft_skin_avatar_enabled

    name = minecraft_name_for(user)
    return nil if name.blank?

    fields = user.custom_fields
    return nil if fields[DISMISSED_FIELD].to_s.casecmp?(name)
    return nil if fields[APPLIED_FIELD].to_s.casecmp?(name)

    # Hat der User bereits ein eigenes Profilbild (nicht von uns), nicht stören.
    if user.uploaded_avatar_id.present? &&
         user.uploaded_avatar_id.to_s != fields[APPLIED_UPLOAD_FIELD].to_s
      return nil
    end

    { name: name, url: skin_url(name) }
  end

  def self.download_and_create_upload(user, name)
    tempfile =
      FileHelper.download(
        skin_url(name),
        max_file_size: SiteSetting.max_image_size_kb.kilobytes,
        tmp_file_name: "minecraft-skin",
        follow_redirect: true,
        skip_rate_limit: true,
      )
    return nil if tempfile.blank?

    UploadCreator.new(tempfile, "minecraft-#{name}.png", type: "avatar").create_for(user.id)
  rescue StandardError => e
    Rails.logger.warn("[minecraft-skin-avatar] Download für #{name} fehlgeschlagen: #{e.message}")
    nil
  ensure
    tempfile&.close!
  end

  def self.set_avatar!(user, upload, name)
    user_avatar = user.user_avatar || user.create_user_avatar!
    user_avatar.custom_upload_id = upload.id
    user_avatar.save!

    user.uploaded_avatar_id = upload.id
    user.save!

    user.custom_fields[APPLIED_FIELD] = name
    user.custom_fields[APPLIED_UPLOAD_FIELD] = upload.id.to_s
    user.save_custom_fields(true)
  end
end
