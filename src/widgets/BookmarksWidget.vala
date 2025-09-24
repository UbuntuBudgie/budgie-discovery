public class BookmarksWidget: Gtk.Box {
    private Gtk.Grid appsLayout = new Gtk.Grid();
    private Budgie.Popover popover;

    public BookmarksWidget(Budgie.Popover parent) {
        Object();
        popover = parent;
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(10);
        get_style_context().add_class("applications-widget");

        var headerWidget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        headerWidget.get_style_context().add_class ("header-widget");
        pack_start(headerWidget, false, true);

        var headerLabel = new Gtk.Label(_("Bookmarks"));
        headerLabel.set_halign(Gtk.Align.START);
        headerLabel.get_style_context().add_class ("header-label");
        headerWidget.pack_start(headerLabel, true);

        var pageLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        pageLayout.set_hexpand(true);
        pageLayout.set_vexpand(true);
        pack_start(pageLayout, true, true, 0);

        appsLayout.get_style_context().add_class("card");
        appsLayout.get_style_context().add_class("p-3");
        appsLayout.set_row_spacing(10);
        appsLayout.set_column_spacing(10);
        appsLayout.set_halign(Gtk.Align.FILL);
        appsLayout.set_valign(Gtk.Align.START);
        pageLayout.pack_start(appsLayout, true, true, 0);

        var scrollView = new Gtk.ScrolledWindow(null, null);
        scrollView.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrollView.set_hexpand(true);
        scrollView.set_vexpand(true);
        scrollView.set_overlay_scrolling(false);
        pack_start(scrollView, true, true, 0);

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
}