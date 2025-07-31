using Config;

public class DiscoveryPopup {
    private Budgie.Popover popover;
    private Gtk.Label greetingLabel;
    private Gdk.Screen screen;

    public DiscoveryPopup(Gtk.Widget parentWidget) {
        screen = parentWidget.get_screen();
        this.popover = new Budgie.Popover(parentWidget);
        this.popover.get_style_context ().add_class ("discovery-popup");

        var popoverLayout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popoverLayout.get_style_context ().add_class ("popup-content");
        this.popover.add(popoverLayout);

        var topRow = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

        greetingLabel = new Gtk.Label("");
        greetingLabel.get_style_context ().add_class ("greeting-label");
        topRow.pack_start (greetingLabel, false);
        popoverLayout.pack_start (topRow, false);

        var g = screen.get_display().get_primary_monitor().get_geometry();
        var popupWidth = g.width / 3;
        var popupHeight = (g.height / 3) * 2;
        popoverLayout.set_size_request(popupWidth, popupHeight);

        load_style_sheet();

        Timeout.add_seconds (1, updateTime);
    }

    public Budgie.Popover getPopover() {
        return this.popover;
    }

    private void load_style_sheet() {
        var css = new Gtk.CssProvider();
        try {
            string css_path = PLUGIN_DIR + "/style.css";
            css.load_from_path(css_path);
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );
        } catch (Error e) {
            warning("Konnte CSS nicht laden: %s", e.message);
        }
    }

    private string get_real_name() {
        var username = Environment.get_user_name();
        try {
            var file = File.new_for_path("/etc/passwd");
            var dis = new DataInputStream(file.read());
            string? line;
            while ((line = dis.read_line(null)) != null) {
                if (line.has_prefix(username + ":")) {
                    var fields = line.split(":");
                    if (fields.length > 4) {
                        return fields[4].split(",")[0];
                    }
                }
            }
        } catch (Error e) {
            // Fehlerbehandlung, falls Datei nicht lesbar
        }
        return username;
    }

    private bool updateTime() {
        var now = new DateTime.now_local ();
        var h = now.get_hour();
        var greetingText = "";

        if(h >= 0 && h <= 10) {
            greetingText = "Good morning";
        } else if(h > 10 && h <= 14) {
            greetingText = "Good day";
        } else if(h > 14 && h <= 18) {
            greetingText = "Good afternoon";
        } else if(h > 18) {
            greetingText = "Good evening";
        }

        var real_name = get_real_name();
        greetingText += ", " + real_name;
        greetingLabel.set_text(greetingText);

        return true;
    }
}