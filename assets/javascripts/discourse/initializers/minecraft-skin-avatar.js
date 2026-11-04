import { apiInitializer } from "discourse/lib/api";
import MinecraftSkinAvatarChoice from "../components/minecraft-skin-avatar-choice";
import MinecraftSkinBanner from "../components/minecraft-skin-banner";

export default apiInitializer((api) => {
  const siteSettings = api.container.lookup("service:site-settings");
  if (!siteSettings.minecraft_skin_avatar_enabled) {
    return;
  }

  api.renderInOutlet("above-main-container", MinecraftSkinBanner);
  api.renderInOutlet("above-main-container", MinecraftSkinAvatarChoice);
});
