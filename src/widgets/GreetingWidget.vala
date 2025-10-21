public class GreetingWidget: Gtk.Box {
    private Gtk.Label greetingLabel;
    private Gtk.Label currentDateLabel = new Gtk.Label("");
    private Gtk.Box rightLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);

    public GreetingWidget() {
        Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
        get_style_context().add_class("header-widget");
        get_style_context().add_class ("pb-5");

        var leftLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        pack_start(leftLayout, true);

        rightLayout.set_halign(Gtk.Align.END);
        rightLayout.set_valign(Gtk.Align.START);
        pack_start(rightLayout, false);

        leftLayout.pack_start(currentDateLabel, false);
        currentDateLabel.set_halign(Gtk.Align.START);
        currentDateLabel.get_style_context().add_class("text-size-small");

        // Initialize the widget
        greetingLabel = new Gtk.Label("");
        greetingLabel.get_style_context().add_class("header-label");
        greetingLabel.set_halign(Gtk.Align.START);
        greetingLabel.set_valign(Gtk.Align.START);
        greetingLabel.set_lines(1);
        leftLayout.pack_start(greetingLabel, false);

        // Set the greeting text
        updateTime();
        Timeout.add_seconds(1, () => {
            updateTime();
            return true;
        });
    }

    public void addButton(Gtk.Widget button) {
        button.set_valign(Gtk.Align.START);
        rightLayout.pack_start(button, false);
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

        currentDateLabel.set_label(now.format("%A, %d. %B"));

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