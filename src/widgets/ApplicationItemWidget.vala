using Gdk;
using Gee;

public class ApplicationItemWidget: Gtk.EventBox {
    private Gtk.Image icon;
    public Gtk.Label label {get; set;}
    private Gtk.Menu menu;

    public ApplicationItemWidget(Budgie.Popover popover, ApplicationItem item) {
        Object();
        var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        
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

        string[] argv = new string[]{item.action.split(" ")[0], null};
        string[] pkexec = new string[]{"pkexec", item.action.split(" ")[0], null};

        this.map.connect(() => {
            menu = new Gtk.Menu();
            var menuItem1 = new Gtk.MenuItem();
            menuItem1.set_label(_("Run"));
            menuItem1.button_press_event.connect(() => {
                popover.hide();
                Idle.add(() => {
                    try {
                        
                        GLib.Process.spawn_async (null, argv, null,
                              SpawnFlags.SEARCH_PATH, null, null);
                    } catch(Error e) {
                        error(e.message);
                    }
                    return false;
                });
                return true;
            });
            menu.add(menuItem1);

            var menuItem2 = new Gtk.MenuItem();
            menuItem2.set_label(_("Run as user \"root\""));
            menuItem2.button_press_event.connect(() => {
                popover.hide();
                Idle.add(() => {
                    try {
                        
                        GLib.Process.spawn_async (null, pkexec, null,
                              SpawnFlags.SEARCH_PATH, null, null);
                    } catch(Error e) {
                        error(e.message);
                    }
                    return false;
                });
                return true;
            });
            menu.add(menuItem2);

            var separator = new Gtk.SeparatorMenuItem ();
            menu.add(separator);

            var menuItem3 = new Gtk.MenuItem();
            menuItem3.set_label(_("Pin to start"));
            menu.add(menuItem3);

            menu.show_all();
        });

        this.button_press_event.connect((event) => {
            if(event.button == Gdk.BUTTON_SECONDARY) {
                menu.popup_at_pointer(event);
            }

            if(event.button == Gdk.BUTTON_PRIMARY) {
                popover.hide();
                Idle.add(() => {
                    try {
                        
                        GLib.Process.spawn_async (null, argv, null,
                              SpawnFlags.SEARCH_PATH, null, null);
                    } catch(Error e) {
                        error(e.message);
                    }
                    return false;
                });
                return true;
            }
            return true;
        });

        add(layout);
        setIcon(item.icon);
        setLabel(item.label);
    }

    private void setIcon(string value) {
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

    private void setLabel(string value) {
        label.set_text(value);
    }
}