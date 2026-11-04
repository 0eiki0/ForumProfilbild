# discourse-minecraft-skin-avatar

Schlägt Usern ihren Minecraft-Kopf (https://mineskin.eu/helm/NAME.png) als Profilbild vor.
Der User kann ihn übernehmen, ein eigenes Bild hochladen oder den Vorschlag ablehnen.

## Installation (Docker)
In `containers/app.yml` unter `hooks -> after_code -> cmd`:

    - git clone https://github.com/0eiki0/forumprofilbild.git

Danach `./launcher rebuild app`.

## Einstellungen (Admin → Plugins)
- `minecraft_skin_avatar_user_field`: exakter Name des Benutzerfelds (Standard: `Minecraft-Name`)
- `minecraft_skin_avatar_url_template`: Bild-URL, `{name}` wird ersetzt
