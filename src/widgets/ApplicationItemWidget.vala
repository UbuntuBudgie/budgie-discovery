using Gdk;
using Gee;

public class ApplicationItemWidget: BasicIconTextWidget {
    private Gtk.Menu menu;

    public ApplicationItemWidget(Budgie.Popover popover, ApplicationItem item) {
        base();
        string[] argv = null;
        try {
            GLib.Shell.parse_argv(item.action, out argv);
        }
        catch(Error e) {
            error("Failed to parse action for app %s: %s", item.label, e.message);
        }

        string[] pkexec = argv != null ? new string[]{"pkexec", argv[0], null} : null;

        this.menu = new Gtk.Menu();
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
        this.menu.add(menuItem1);

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
        this.menu.add(menuItem2);

        var separator = new Gtk.SeparatorMenuItem ();
        this.menu.add(separator);

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
        this.menu.add(menuItem3);
        this.menu.show_all();

        this.button_press_event.connect((event) => {
            if(event.button == Gdk.BUTTON_SECONDARY) {
                this.menu.popup_at_pointer(event);
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

        setIcon(item.icon);
        setLabel(item.label);
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