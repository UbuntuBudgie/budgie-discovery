using Gee;

public class BookmarksWidget: Gtk.Box {
    private Gtk.Grid appsLayout = new Gtk.Grid();
    private Gtk.Grid bookmarksLayout = new Gtk.Grid();
    private Gtk.Label applicationsLabel;
    private Budgie.Popover popover;
    private static int ITEM_SIZE = 100;
    private FileWatcherSevice bookmarkService;

    public BookmarksWidget(Budgie.Popover parent) {
        Object(orientation: Gtk.Orientation.VERTICAL, spacing: 10);
        popover = parent;
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

        applicationsLabel = new Gtk.Label(_("Favorite Applications"));
        applicationsLabel.get_style_context().add_class("text-size-small");
        applicationsLabel.get_style_context().add_class("section-label");
        applicationsLabel.set_halign(Gtk.Align.START);
        applicationsLabel.set_valign(Gtk.Align.END);
        pageLayout.pack_start(applicationsLabel, false, false, 0);

        appsLayout.get_style_context().add_class("card");
        appsLayout.get_style_context().add_class("frame");
        appsLayout.get_style_context().add_class("p-3");
        appsLayout.get_style_context().add_class("mb-5");
        appsLayout.set_row_spacing(10);
        appsLayout.set_column_spacing(10);
        appsLayout.set_halign(Gtk.Align.FILL);
        appsLayout.set_valign(Gtk.Align.START);
        pageLayout.pack_start(appsLayout, false, false, 0);

        var locationsLabel = new Gtk.Label(_("Locations"));
        locationsLabel.get_style_context().add_class("text-size-small");
        locationsLabel.get_style_context().add_class("section-label");
        locationsLabel.set_halign(Gtk.Align.START);
        pageLayout.pack_start(locationsLabel, false, false, 0);

        bookmarksLayout.get_style_context().add_class("card");
        bookmarksLayout.get_style_context().add_class("frame");
        bookmarksLayout.get_style_context().add_class("p-3");
        bookmarksLayout.set_row_spacing(10);
        bookmarksLayout.set_column_spacing(10);
        bookmarksLayout.set_halign(Gtk.Align.FILL);
        bookmarksLayout.set_valign(Gtk.Align.START);
        pageLayout.pack_start(bookmarksLayout, false, false, 0);

        var bookmarksFile = Environment.get_user_config_dir () + "/gtk-3.0/bookmarks";
        if(!FileUtils.test(bookmarksFile, GLib.FileTest.EXISTS)) {
            // check, if directory exists
            var bookmarksDir = Environment.get_user_config_dir () + "/gtk-3.0";
            if(!FileUtils.test(bookmarksDir, GLib.FileTest.IS_DIR)) {
                DirUtils.create_with_parents(bookmarksDir, 0700);
                if(!FileUtils.test(bookmarksDir, GLib.FileTest.IS_DIR)) {
                    warning("directory %s cant be created, aborting".printf(bookmarksDir));
                    Process.exit(1);
                }
            }

            // directory exists, touch file
            try {
                GLib.File.new_for_path(bookmarksFile).create(GLib.FileCreateFlags.NONE, null);
            } catch(Error e) {
                warning("file %s cant be created, aborting".printf(bookmarksFile));
                Process.exit(1);
            }
        }

        SettingsUtils.checkSettingsFile();
        var settingsFile = SettingsUtils.getSettingsFilePath();

        bookmarkService = new FileWatcherSevice();
        bookmarkService.watchFile(bookmarksFile);
        bookmarkService.watchFile(settingsFile);

        bookmarkService.fileChanged.connect((path) => {
            if( path == bookmarksFile) updateBookmarksLayout();
            if( path == settingsFile) updateAppsLayout();
        });
        bookmarkService.start_service();

        pageLayout.show_all();
        
        map.connect(() => {
            updateAppsLayout();
        });
    }

    ~BookmarksWidget() {
        bookmarkService.stop_service();
    }

    private void updateAppsLayout() {
        appsLayout.foreach((child) => appsLayout.remove(child));

        int col = 0;
        int row = 0;
        int maxCols = 6;

        var items = FavoritesRepository.getFavorites();
        if(items.size == 0) {
            applicationsLabel.hide();
            appsLayout.hide();
            return;
        }

        appsLayout.get_style_context().add_class("card");
        applicationsLabel.show();
        
        foreach (var item in items) {
            var iconWidget = new ApplicationItemWidget(popover, item);
            iconWidget.set_size_request(ITEM_SIZE, ITEM_SIZE);
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

        Idle.add(() => {
            int col = 0;
            int row = 0;
            int maxCols = 6;

            var items = BookmarkRepository.getBookmarks();
            foreach (var item in items) {
                var bookmarkWidget = new BookmarkItemWidget(popover, item);
                bookmarkWidget.button_press_event.connect((event) => {
                    if (event.button == 1) {
                        string uri = item.uri;
                        if (!uri.contains("://")) {
                            var f = File.new_for_path(uri);
                            uri = f.get_uri();
                        }

                        try {
                            if(uri.index_of("smb://") == 0) {
                                var f = File.new_for_uri(item.uri);
                                var op = new MountOperation();
                            
                                f.mount_enclosing_volume.begin(MountMountFlags.NONE, op, null, (obj, res) => {
                                    try {
                                        f.mount_enclosing_volume.end(res);
                                        AppInfo.launch_default_for_uri(item.uri, null);
                                    } catch (Error e) {
                                        warning("Mount failed: %s", e.message);
                                    }
                                });
                            } else {
                                AppInfo.launch_default_for_uri(uri, null);
                            }
                            popover.hide();
                        } catch (Error e) {
                            message(e.message);
                        }
                    }
                    return true;
                });

                bookmarkWidget.set_size_request(ITEM_SIZE, ITEM_SIZE);
                bookmarksLayout.attach(bookmarkWidget, col, row, 1, 1);

                col++;
                if (col >= maxCols) {
                    col = 0;
                    row++;
                }
            }

            bookmarksLayout.show_all();
            return false;
        }, Priority.DEFAULT);
    }
}