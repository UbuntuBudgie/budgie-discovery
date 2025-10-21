using Gdk;

public class BasicIconTextWidget: Gtk.EventBox {
    protected Gtk.Image icon;
    protected Gtk.Label label;

    public BasicIconTextWidget() {
        Object();

        var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        layout.get_style_context().add_class("application-item");
        
        icon = new Gtk.Image();
        icon.set_pixel_size(48);

        label = new Gtk.Label("");
        label.set_justify(Gtk.Justification.CENTER);
        label.set_valign(Gtk.Align.START);
        label.set_xalign(0.5f);
        label.set_line_wrap(true);
        label.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR);
        label.set_width_chars(12);
        label.set_max_width_chars(12);
        label.set_lines(2);
        label.get_style_context().add_class("text-size-small");

        layout.pack_start(icon, false, false, 0);
        layout.pack_start(label, true, true, 0);
        add(layout);

        realize.connect(() => {
            add_events(Gdk.EventMask.POINTER_MOTION_MASK |
                Gdk.EventMask.ENTER_NOTIFY_MASK |
                Gdk.EventMask.LEAVE_NOTIFY_MASK);
        });

        this.enter_notify_event.connect((event) => {
            //layout.get_style_context().add_class("hover");
            layout.set_state_flags(Gtk.StateFlags.PRELIGHT, false); // aktiviert :hover
            return false;
        });
        this.leave_notify_event.connect((event) => {
            //layout.get_style_context().remove_class("hover");
            layout.unset_state_flags(Gtk.StateFlags.PRELIGHT); // deaktiviert :hover
            return false;
        });
    }

    public void setIcon(string value) {
        if(value == null) {
            message("Unable to set icon for app %s", label.get_text());
            return;
        }

        if(GLib.Path.is_absolute(value)) {
            try {
                var pixbuf = new Pixbuf.from_file(value)
                    .scale_simple(icon.pixel_size, icon.pixel_size, Gdk.InterpType.BILINEAR);
                icon.pixbuf = pixbuf;
            } catch(Error e) {
                message("ERROR: %s", e.message);
            }
            return;
        }
        icon.icon_name = value;
    }

    public void setLabel(string value) {
        label.set_text(value);
    }
}