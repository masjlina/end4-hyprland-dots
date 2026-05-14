-- Default scripts
local SCRIPTS = os.getenv("HOME") .. "/.config/hypr/custom/scripts"

-- put former exec-once commands inside the func
-- and former exec commands outside

hl.on("hyprland.start", function ()

    -- Bar, wallpaper
    hl.exec_cmd("variety -n")
    -- hl.exec_cmd("awww-daemon --format xrgb")

    -- Input method
    hl.exec_cmd("fcitx5")

    -- Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1 || /usr/libexec/polkit-kde-authentication-agent-1 || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1")

    -- My apps
    hl.exec_cmd("syncthing --no-browser")
    hl.exec_cmd("kdeconnectd")
    hl.exec_cmd("spotify-launcher")

    hl.exec_cmd("obsidian --no-sandbox --ozone-platform=x11 --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations %U")

    hl.exec_cmd("firefox")

    -- Other

end)
