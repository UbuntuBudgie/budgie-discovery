public class GreetingWidget {
    private Gtk.Label greetingLabel;

    public Gtk.Label getLabel() {
        return greetingLabel;
    }

    public GreetingWidget() {
        // Initialize the widget
        greetingLabel = new Gtk.Label("");
        greetingLabel.get_style_context().add_class("greeting-label");
        greetingLabel.set_halign(Gtk.Align.START);
        greetingLabel.set_valign(Gtk.Align.START);
        greetingLabel.set_lines(1);

        // Set the greeting text
        updateTime();
        Timeout.add_seconds(1, () => {
            updateTime();
            return true;
        });
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
            greetingText = _("Good morning");
        } else if(h > 10 && h <= 14) {
            greetingText = _("Good day");
        } else if(h > 14 && h <= 18) {
            greetingText = _("Good afternoon");
        } else if(h > 18) {
            greetingText = _("Good evening");
        }

        var real_name = get_real_name();
        greetingText += ", " + real_name;
        greetingLabel.set_text(greetingText);

        return true;
    }
}