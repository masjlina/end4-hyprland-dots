-- ######### Input method ##########
-- https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland

hl.env("EDITOR", "nvim")

hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "fcitx")
hl.env("INPUT_METHOD", "fcitx")

-- ############ Wayland #############

hl.env("GDK_BACKEND", "wayland,x11")

hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- ######## Others ########

hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2")

-- XWayland apps scale fix
-- https://wiki.hyprland.org/Configuring/XWayland/

hl.env("GDK_SCALE", "1")

-- Firefox

hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Electron >28 apps

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- NVIDIA

hl.env("LIBVA_DRIVER_NAME", "nvidia")

-- Optional NVIDIA / VM variables

-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")

-- hl.env("GBM_BACKEND", "nvidia-drm")

-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
-- hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- VM / software rendering

-- hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

-- Firefox VAAPI workaround

-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
