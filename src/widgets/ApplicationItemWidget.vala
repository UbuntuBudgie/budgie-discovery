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

        string[] argv = null;
        try {
            GLib.Shell.parse_argv(item.action, out argv);
        }
        catch(Error e) {
            error("Failed to parse action for app %s: %s", item.label, e.message);
        }

        string[] pkexec = argv != null ? new string[]{"pkexec", argv[0], null} : null;

        menu = new Gtk.Menu();
        this.map.connect(() => {
            var menuItem1 = new Gtk.MenuItem();
            menuItem1.set_label(_("Run"));
            menuItem1.activate.connect(() => {
                popover.hide();
                try {
                    if(argv == null) return;   
                    GLib.Process.spawn_async (null, new string[]{argv[0]}, null,
                            SpawnFlags.SEARCH_PATH, null, null);
                } catch(Error e) {
                    error(e.message);
                }
            });
            menu.add(menuItem1);

            var menuItem2 = new Gtk.MenuItem();
            menuItem2.set_label(_("Run as user \"root\""));
            menuItem2.activate.connect(() => {
                popover.hide();
                try {
                    if(pkexec == null) return;
                    GLib.Process.spawn_async (null, pkexec, null,
                            SpawnFlags.SEARCH_PATH, null, null);
                } catch(Error e) {
                    error(e.message);
                }
            });
            menu.add(menuItem2);

            var separator = new Gtk.SeparatorMenuItem ();
            menu.add(separator);

            var menuItem3 = new Gtk.MenuItem();
            if(!item.isFavorite)
                menuItem3.set_label(_("Pin to start"));
            else
                menuItem3.set_label(_("Unpin from start"));
                
            menuItem3.activate.connect(() => {
                if(item.isFavorite)
                    removeFromFavorites(item);
                else
                    addToFavorites(item);
            });
            menu.add(menuItem3);

            menu.show_all();
        });

        this.button_press_event.connect((event) => {
            if(event.button == Gdk.BUTTON_SECONDARY) {
                menu.popup_at_pointer(event);
            }

            if(event.button == Gdk.BUTTON_PRIMARY) {
                popover.hide();
                try {
                    if(argv == null) return true;
                    GLib.Process.spawn_async (null, new string[]{argv[0]}, null,
                            SpawnFlags.SEARCH_PATH, null, null);
                } catch(Error e) {
                    error(e.message);
                }
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

    private void setLabel(string value) {
        label.set_text(value);
    }

    private void addToFavorites(ApplicationItem item) {
        var favorites = FavoritesRepository.getFavorites();
        if(favorites.contains(item)) {
            return;
        }

        favorites.add(item);
        FavoritesRepository.saveFavorites(favorites);
    }

    private void removeFromFavorites(ApplicationItem item) {
        var favorites = FavoritesRepository.getFavorites();
        if(!favorites.contains(item)) {
            return;
        }
        
        favorites.remove(item);
        FavoritesRepository.saveFavorites(favorites);
    }
}