public class ApplicationItemWidget: Gtk.Box {
    private Gtk.Image icon;
    private Gtk.Label label;

    public ApplicationItemWidget() {
        Object();
        set_orientation (Gtk.Orientation.VERTICAL);
        set_spacing (5);

        icon = new Gtk.Image();
        label = new Gtk.Label("");
        label.get_style_context().add_class("text-secondary");

        pack_start (icon, false);
        pack_start(label, false);

        label.set_ellipsize(Pango.EllipsizeMode.END);
        label.set_line_wrap(true);
        label.set_lines(2);
        label.max_width_chars = 30;
    }

    public void setIcon(string icon) {

    }

    public void setLabel(string value) {
        label.set_text(value);
    }
}