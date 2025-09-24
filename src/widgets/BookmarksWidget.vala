using Gee;

public class BookmarksWidget: Gtk.Box {
    private Gtk.Grid appsLayout = new Gtk.Grid();
    private Gtk.Box bookmarksLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    private Budgie.Popover popover;

    public BookmarksWidget(Budgie.Popover parent) {
        Object();
        popover = parent;
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(10);
        get_style_context().add_class("applications-widget");

        var headerWidget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        headerWidget.get_style_context().add_class ("header-widget");
        headerWidget.get_style_context().add_class ("pb-1");
        pack_start(headerWidget, false, true);

        var headerLabel = new Gtk.Label(_("Bookmarks"));
        headerLabel.set_halign(Gtk.Align.START);
        headerLabel.get_style_context().add_class ("header-label");
        headerWidget.pack_start(headerLabel, true);

        var pageLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        pageLayout.set_hexpand(true);
        pageLayout.set_vexpand(true);

        var scrollView = new Gtk.ScrolledWindow(null, null);
        scrollView.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrollView.set_hexpand(true);
        scrollView.set_vexpand(true);
        scrollView.set_overlay_scrolling(false);
        scrollView.add(pageLayout);
        pack_start(scrollView, true, true, 0);

        appsLayout.get_style_context().add_class("card");
        appsLayout.get_style_context().add_class("p-3");
        appsLayout.set_row_spacing(10);
        appsLayout.set_column_spacing(10);
        appsLayout.set_halign(Gtk.Align.FILL);
        appsLayout.set_valign(Gtk.Align.START);
        pageLayout.pack_start(appsLayout, true, true, 0);

        bookmarksLayout.get_style_context().add_class("card");
        bookmarksLayout.get_style_context().add_class("p-3");
        bookmarksLayout.set_halign(Gtk.Align.FILL);
        bookmarksLayout.set_valign(Gtk.Align.START);
        pageLayout.pack_start(bookmarksLayout, true, true, 0);

        var bookmarkService = new BookmarkService();
        bookmarkService.bookmarksChanged.connect(() => {
            updateBookmarksLayout();
        });
        bookmarkService.start_service();

        pageLayout.show_all();
        updateAppsLayout();
    }

    private void updateAppsLayout() {
        appsLayout.foreach((child) => appsLayout.remove(child));

        int col = 0;
        int row = 0;
        int maxCols = 6;

        var items = FavoritesRepository.getFavorites();

        foreach (var item in items) {
            var iconWidget = new ApplicationItemWidget(popover, item);
            iconWidget.set_size_request(100, 100);
            appsLayout.attach(iconWidget, col, row, 1, 1);

            col++;
            if (col >= maxCols) {
                col = 0;
                row++;
            }
        }
        appsLayout.show_all();
    }

    private void updateBookmarksLayout() {
        bookmarksLayout.foreach((child) => bookmarksLayout.remove(child));

        var items = BookmarkRepository.getBookmarks();
        foreach (var item in items) {
            var bookmarkRow = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            bookmarkRow.get_style_context().add_class("bookmark-row");
            bookmarkRow.set_halign(Gtk.Align.FILL);
            bookmarkRow.set_valign(Gtk.Align.CENTER);

            var eventBox = new Gtk.EventBox();
            eventBox.add(bookmarkRow);

            Icon gicon;
            try {
                var f = File.new_for_uri(item.uri);
                if (f.has_uri_scheme("file")) {
                    // Lokales File → Content-Type Icon
                    var info = f.query_info("standard::icon", 0, null);
                    gicon = info.get_icon();
                } else {
                    // Netzwerk / sonstige URIs → fallback auf "folder"
                    gicon = new ThemedIcon("folder");
                }
            } catch (Error e) {
                gicon = new ThemedIcon("folder");
            }

            var icon = new Gtk.Image();
            icon.set_from_gicon(gicon, Gtk.IconSize.BUTTON);
            icon.set_pixel_size(16);
            icon.set_halign(Gtk.Align.START);
            icon.set_valign(Gtk.Align.CENTER);
            bookmarkRow.pack_start(icon, false, false, 0);

            var label = new Gtk.Label(item.name);
            label.set_halign(Gtk.Align.START);
            label.set_valign(Gtk.Align.CENTER);
            label.get_style_context().add_class("bookmark-label");
            bookmarkRow.pack_start(label, true, true, 0);

            eventBox.add_events(Gdk.EventMask.BUTTON_PRESS_MASK);
            eventBox.button_press_event.connect((event) => {
                message("Start URI: %s".printf(item.uri));
                if (event.button == 1) {
                    string uri = item.uri;
                    if (!uri.contains("://")) {
                        var f = File.new_for_path(uri);
                        uri = f.get_uri();
                    }

                    try {
                        AppInfo.launch_default_for_uri(uri, null);
                        popover.hide();
                    } catch (Error e) {
                        message(e.message);
                    }
                }
                return true;
            });

            bookmarksLayout.pack_start(eventBox, false, true, 5);
        }

        bookmarksLayout.show_all();
    }
}