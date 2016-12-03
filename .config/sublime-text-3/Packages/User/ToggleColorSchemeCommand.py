import sublime, sublime_plugin

class ToggleColorSchemeCommand(sublime_plugin.TextCommand):
    def run(self, edit, **args):

        schemes = [
        "Packages/Seti_UX/Seti.tmTheme",
        "Packages/Color Scheme - Default/LAZY.tmTheme",
        "Packages/Color Scheme - Default/Solarized (Light).tmTheme",
        "Packages/Theme - Spacegray/base16-ocean.light.tmTheme",
        "Packages/Theme - Spacegray/base16-ocean.dark.tmTheme",
        "Packages/Color Scheme - Default/Monokai Bright.tmTheme",
        "Packages/Seti_UX/Seti.tmTheme"
        ]
        current_scheme = self.view.settings().get("color_scheme")
        # if i = schemes.index(current_scheme)
        i = args["theme_number"]
        new_scheme = schemes[int(i)]
        self.view.settings().set("color_scheme", new_scheme)
        self.load_settings().set('color_scheme', new_scheme)

    def load_settings(self):
        return sublime.load_settings('Preferences.sublime-settings')