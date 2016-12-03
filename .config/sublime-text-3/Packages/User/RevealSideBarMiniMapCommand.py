import sublime, sublime_plugin

class RevealSideBarMiniMapCommand(sublime_plugin.WindowCommand):
    def run(self):
        self.window.run_command("toggle_side_bar")
        self.window.run_command("toggle_minimap")
        self.window.run_command("hide_panel")