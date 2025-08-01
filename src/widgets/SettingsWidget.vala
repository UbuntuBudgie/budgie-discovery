public class SettingsWidget: Gtk.Box {
    private Gtk.Label settingsLabel;

    public SettingsWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(5);
        get_style_context().add_class("settings-widget");

        settingsLabel = new Gtk.Label("Settings will be displayed here.");
        settingsLabel.set_halign(Gtk.Align.CENTER);
        settingsLabel.set_valign(Gtk.Align.START);
        pack_start(settingsLabel, true, true, 0);
    }

    public void update_settings(string settingsContent) {
        settingsLabel.set_text(settingsContent);
    }
}