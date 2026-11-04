import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class MinecraftSkinBanner extends Component {
  @service currentUser;
  @service toasts;

  @tracked hidden = false;
  @tracked saving = false;

  get suggestion() {
    return this.currentUser?.minecraft_skin_suggestion;
  }

  get show() {
    return !this.hidden && !!this.suggestion;
  }

  @action
  async apply() {
    this.saving = true;
    try {
      const result = await ajax("/minecraft-skin-avatar/apply", {
        type: "POST",
      });
      this.currentUser.set("avatar_template", result.avatar_template);
      this.currentUser.set("minecraft_skin_suggestion", null);
      this.hidden = true;
      this.toasts?.success({
        duration: 3000,
        data: { message: i18n("minecraft_skin_avatar.applied") },
      });
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }

  @action
  uploadOwn() {
    DiscourseURL.routeTo(
      `/u/${this.currentUser.username_lower}/preferences/account`
    );
  }

  @action
  async dismiss() {
    this.hidden = true;
    try {
      await ajax("/minecraft-skin-avatar/dismiss", { type: "POST" });
      this.currentUser.set("minecraft_skin_suggestion", null);
    } catch (e) {
      popupAjaxError(e);
    }
  }

  <template>
    {{#if this.show}}
      <div class="minecraft-skin-banner">
        <img
          class="minecraft-skin-banner__preview"
          src={{this.suggestion.url}}
          alt={{this.suggestion.name}}
          width="72"
          height="72"
        />
        <div class="minecraft-skin-banner__content">
          <h3>{{i18n "minecraft_skin_avatar.title"}}</h3>
          <p>{{i18n
              "minecraft_skin_avatar.description"
              name=this.suggestion.name
            }}</p>
          <div class="minecraft-skin-banner__actions">
            <DButton
              @action={{this.apply}}
              @label="minecraft_skin_avatar.apply"
              @icon="check"
              @disabled={{this.saving}}
              class="btn-primary"
            />
            <DButton
              @action={{this.uploadOwn}}
              @label="minecraft_skin_avatar.upload_own"
              @icon="upload"
              class="btn-default"
            />
            <DButton
              @action={{this.dismiss}}
              @label="minecraft_skin_avatar.dismiss"
              class="btn-flat"
            />
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
