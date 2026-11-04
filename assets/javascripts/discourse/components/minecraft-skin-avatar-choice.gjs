import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import DButton from "discourse/components/d-button";
import AvatarSelectorModal from "discourse/components/modal/avatar-selector";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

const MODAL_BODY_SELECTOR = ".avatar-selector-modal .d-modal__body";

// Discourse bietet im Profilbild-Fenster keinen Plugin-Outlet. Diese Komponente
// läuft daher im Hintergrund mit, erkennt über den Modal-Service, wann das
// Profilbild-Fenster des eigenen Accounts offen ist, und rendert dann per
// in-element eine zusätzliche "Minecraft-Skin"-Zeile in das Fenster.
export default class MinecraftSkinAvatarChoice extends Component {
  @service currentUser;
  @service modal;

  @tracked target = null;
  @tracked saving = false;

  watchModal = modifier(() => {
    let cancelled = false;
    let tries = 0;

    const find = () => {
      if (cancelled) {
        return;
      }
      const el = document.querySelector(MODAL_BODY_SELECTOR);
      if (el) {
        this.target = el;
      } else if (tries++ < 40) {
        setTimeout(find, 50);
      }
    };
    setTimeout(find, 0);

    return () => {
      cancelled = true;
      this.target = null;
    };
  });

  get info() {
    return this.currentUser?.minecraft_skin_avatar;
  }

  get isOwnAvatarModalOpen() {
    const active = this.modal.activeModal;
    if (!this.info || active?.component !== AvatarSelectorModal) {
      return false;
    }
    const model = active.opts?.model;
    if (model?.deferSave) {
      return false;
    }
    // Nur für das eigene Profil, nicht wenn ein Admin einen anderen User bearbeitet
    return !model?.user || model.user.id === this.currentUser.id;
  }

  @action
  async apply() {
    this.saving = true;
    try {
      await ajax("/minecraft-skin-avatar/apply", { type: "POST" });
      this.modal.close();
      window.location.reload();
    } catch (e) {
      popupAjaxError(e);
      this.saving = false;
    }
  }

  <template>
    {{#if this.isOwnAvatarModalOpen}}
      <span hidden {{this.watchModal}}></span>
      {{#if this.target}}
        {{#in-element this.target insertBefore=null}}
          <div class="avatar-choice avatar-choice--minecraft">
            {{! leere erste Spalte, damit die Zeile mit den Radio-Buttons fluchtet }}
            <span class="minecraft-skin-avatar-choice__spacer"></span>
            <label class="radio">
              <img
                class="avatar minecraft-skin-avatar-choice__preview"
                src={{this.info.url}}
                alt={{this.info.name}}
                width="48"
                height="48"
              />
              <span>
                {{i18n
                  "minecraft_skin_avatar.choice_label"
                  name=this.info.name
                }}
              </span>
            </label>
            {{#if this.info.active}}
              <span class="minecraft-skin-avatar-choice__active">
                {{i18n "minecraft_skin_avatar.choice_active"}}
              </span>
            {{else}}
              <DButton
                @action={{this.apply}}
                @label="minecraft_skin_avatar.choice_apply"
                @icon="check"
                @disabled={{this.saving}}
                class="btn-default minecraft-skin-avatar-choice__apply"
              />
            {{/if}}
          </div>
        {{/in-element}}
      {{/if}}
    {{/if}}
  </template>
}
