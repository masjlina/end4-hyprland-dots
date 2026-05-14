-- ######## Unity window rules ########

local unity = "^(Unity)$"
local cursor_center = {
    "(cursor_x-(window_w*0.5))",
    "(cursor_y-(window_h*0.5))"
}

local function unity_rule(title, props)
    props.match = {
        class = unity,
        title = title
    }

    hl.window_rule(props)
end

-- Certain windows need minimum sizes
-- https://discussions.unity.com/t/engine-menus-can-only-be-opened-once/1521080/3

unity_rule("^(UI Toolkit Debugger)$", {
    min_size = {250, 250}
})

unity_rule("^(Background Tasks)$", {
    min_size = {500, 250}
})

unity_rule("^(Mod Builder)$", {
    min_size = {500, 250}
})

unity_rule("^(Profiler)$", {
    min_size = {500, 250}
})

unity_rule("^(Render Graph Viewer)$", {
    min_size = {500, 250}
})

unity_rule("^(Game)$", {
    min_size = {500, 250}
})

unity_rule("^(Shortcuts)$", {
    min_size = {500, 250}
})

unity_rule("^(NormalMap settings)$", {
    min_size = {500, 250}
})

-- Tooltips stealing focus
-- https://discussions.unity.com/t/unset-tooltip-titles/1522964

unity_rule("^(UnityTooltipWindow)$", {
    no_focus = true
})

-- AssetUsageDetector tooltip

unity_rule("^(AssetUsageDetectorNamespace.SearchResultTooltip)$", {
    min_size = {25, 25}
})

unity_rule("^(AssetUsageDetectorNamespace.SearchResultTooltip)$", {
    size = {25, 25}
})

unity_rule("^(AssetUsageDetectorNamespace.SearchResultTooltip)$", {
    no_focus = true
})

-- Preferences

unity_rule("^(Preferences)$", {
    min_size = {1000, 600}
})

unity_rule("^(Preferences)$", {
    move = cursor_center
})

-- Project Settings

unity_rule("^(Project Settings)$", {
    min_size = {1000, 600}
})

unity_rule("^(Project Settings)$", {
    move = cursor_center
})

-- Package Manager

unity_rule("^(Package Manager)$", {
    min_size = {900, 800}
})

unity_rule("^(Package Manager)$", {
    move = cursor_center
})

-- Package Manager Dropdown

unity_rule("^(UnityEditor.PackageManager.UI.Internal.DropdownContainer)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.PackageManager.UI.Internal.DropdownContainer)$", {
    min_size = {200, 50}
})

unity_rule("^(UnityEditor.PackageManager.UI.Internal.DropdownContainer)$", {
    stay_focused = true
})

-- Font Asset Creator

unity_rule("^(Font Asset Creator)$", {
    move = cursor_center
})

unity_rule("^(Font Asset Creator)$", {
    min_size = {1050, 750}
})

-- Icon Selector

unity_rule("^(UnityEditor.IconSelector)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.IconSelector)$", {
    min_size = {250, 250}
})

-- Color Picker

unity_rule("^(Color)$", {
    move = cursor_center
})

unity_rule("^(Color)$", {
    min_size = {250, 500}
})

unity_rule("^(Color)$", {
    stay_focused = true
})

unity_rule("^(Color)$", {
    opaque = true
})

-- HDR Color Picker

unity_rule("^(HDR Color)$", {
    move = cursor_center
})

unity_rule("^(HDR Color)$", {
    min_size = {250, 500}
})

unity_rule("^(HDR Color)$", {
    stay_focused = true
})

unity_rule("^(HDR Color)$", {
    opaque = true
})

-- Gradient

unity_rule("^(Gradient Editor.*)(.*)$", {
    move = cursor_center
})

unity_rule("^(Gradient Editor.*)(.*)$", {
    min_size = {400, 200}
})

-- HDR Gradient

unity_rule("^(HDR Gradient Editor.*)(.*)$", {
    move = cursor_center
})

unity_rule("^(HDR Gradient Editor.*)(.*)$", {
    min_size = {500, 200}
})

-- Object Selection

unity_rule("^(Select)(.*)$", {
    move = cursor_center
})

unity_rule("^(Select)(.*)$", {
    min_size = {250, 250}
})

-- Select Object

unity_rule("^(Select Object)(.*)$", {
    move = cursor_center
})

unity_rule("^(Select Object)(.*)$", {
    min_size = {250, 250}
})

unity_rule("^(Select Object)(.*)$", {
    stay_focused = true
})

-- Mesh Selection

unity_rule("^(Select Mesh)(.*)$", {
    move = cursor_center
})

unity_rule("^(Select Mesh)(.*)$", {
    min_size = {250, 250}
})

-- Input System Binding

unity_rule("^(UnityEngine.InputSystem.Editor.AdvancedDropdownWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEngine.InputSystem.Editor.AdvancedDropdownWindow)$", {
    min_size = {250, 300}
})

unity_rule("^(UnityEngine.InputSystem.Editor.AdvancedDropdownWindow)$", {
    stay_focused = true
})

-- Annotation Window

unity_rule("^(UnityEditor.AnnotationWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.AnnotationWindow)$", {
    min_size = {250, 700}
})

unity_rule("^(UnityEditor.AnnotationWindow)$", {
    stay_focused = true
})

-- Add Override

unity_rule("^(UnityEditor.Rendering.FilterWindow)(.*)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.Rendering.FilterWindow)(.*)$", {
    min_size = {250, 250}
})

unity_rule("^(UnityEditor.Rendering.FilterWindow)$", {
    stay_focused = true
})

-- Game Object Selection

unity_rule("^(Select Game Object)(.*)$", {
    move = cursor_center
})

unity_rule("^(Select Game Object)(.*)$", {
    min_size = {250, 300}
})

unity_rule("^(Select Game Object)(.*)$", {
    stay_focused = true
})

-- Localization Entry

unity_rule("^(Select string table entry)(.*)$", {
    move = cursor_center
})

unity_rule("^(Select string table entry)(.*)$", {
    min_size = {500, 500}
})

unity_rule("^(Select string table entry)(.*)$", {
    stay_focused = true
})

-- Animation Curve

unity_rule("^(Curve)(.*)$", {
    move = cursor_center
})

unity_rule("^(Curve)(.*)$", {
    min_size = {500, 500}
})

unity_rule("^(Curve)$", {
    stay_focused = true
})

-- Add Component

unity_rule("^(UnityEditor.AddComponent.AddComponentWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.AddComponent.AddComponentWindow)$", {
    min_size = {230, 300}
})

unity_rule("^(UnityEditor.AddComponent.AddComponentWindow)$", {
    stay_focused = true
})

-- Shader dropdown

unity_rule("^(UnityEditor.IMGUI.Controls.AdvancedDropdownWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.IMGUI.Controls.AdvancedDropdownWindow)$", {
    min_size = {250, 250}
})

unity_rule("^(UnityEditor.IMGUI.Controls.AdvancedDropdownWindow)$", {
    stay_focused = true
})

-- Shader Graph Add Node

unity_rule("^(UnityEditor.Searcher.SearcherWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.Searcher.SearcherWindow)$", {
    min_size = {250, 250}
})

unity_rule("^(UnityEditor.Searcher.SearcherWindow)$", {
    stay_focused = true
})

-- VFX Graph

unity_rule("^(UnityEditor.VFX.UI.VFXFilterWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.VFX.UI.VFXFilterWindow)$", {
    min_size = {250, 500}
})

unity_rule("^(UnityEditor.VFX.UI.VFXFilterWindow)$", {
    stay_focused = true
})

-- Tile Palette

unity_rule("^(Tile Palette)$", {
    move = cursor_center
})

unity_rule("^(Tile Palette)$", {
    min_size = {500, 900}
})

unity_rule("^(Tile Palette)$", {
    stay_focused = true
})

-- UI Builder

unity_rule("^(UI Builder)$", {
    move = cursor_center
})

unity_rule("^(UI Builder)$", {
    min_size = {1000, 750}
})

-- UI Toolkit Windows

unity_rule("^(Nisualizer Scene Creator)$", {
    min_size = {200, 50}
})

-- Misc move rules

unity_rule("^(UnityEditor.Rendering.FilterWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEditor.IMGUI.Controls.AdvancedDropdownWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEngine.InputSystem.Editor.AdvancedDropdownWindow)$", {
    move = cursor_center
})

unity_rule("^(UnityEditorInternal.AddCurvesPopup)$", {
    move = cursor_center
})

unity_rule("^(UnityEngine.InputSystem.Editor.AdvancedDropdownWindow)$", {
    min_size = {250, 500}
})

-- Themes

unity_rule("^(Theme Settings)$", {
    min_size = {250, 250}
})

unity_rule("^(Create Theme)$", {
    min_size = {250, 250}
})
