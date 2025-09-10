using Gdk;

public class ApplicationItemWidget: Gtk.Box {
    private Gtk.Image icon;
    public Gtk.Label label {get; set;}

    public ApplicationItemWidget() {
        Object();
        set_orientation (Gtk.Orientation.VERTICAL);
        set_spacing (5);

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

        pack_start(icon, false, false, 0);
        pack_start(label, true, true, 0);
    }

    public void setIcon(string value) {
        if(value == null) {
            message("Unable to set icon for app %s", label.get_text());
            return;
        }

        if(value.index_of("/") == 0) {
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