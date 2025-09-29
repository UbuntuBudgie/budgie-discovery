using Config;
using GLib;

public class SettingsWindow: Gtk.Window {
    Gtk.Notebook notebook;
    public Json.Array feeds;
    private Json.Node rootNode;
    private string filePath;

    public SettingsWindow() {
        Object();
        set_title("Settings");
        set_type_hint(Gdk.WindowTypeHint.DIALOG);
        gravity = Gdk.Gravity.CENTER;
        set_default_size (640, 480);
        get_style_context().add_class("discovery-settings");

        var settingsPath = "%s/%s".printf(Environment.get_user_config_dir(), "discovery-applet").to_string ();
        message("Checking SettingsPath %s", settingsPath);

        if(FileUtils.test(settingsPath, FileTest.IS_DIR) == false) {
            message("Creating config directory %s", settingsPath);
            DirUtils.create_with_parents(settingsPath, 0755);
            if(FileUtils.test(settingsPath, FileTest.IS_DIR) == false) {
                stderr.printf("Could not create config directory: %s\n", settingsPath);
                Process.exit (1);
            }
        }

        filePath = "%s/%s".printf(settingsPath, "settings.json");
        if(FileUtils.test(filePath, FileTest.EXISTS) == false) {
            try {
                message("Touching file %s", filePath);

                var file = File.new_for_path(filePath);
                var outputStream = file.create(FileCreateFlags.NONE);
                outputStream.write("{}".data, null);
                outputStream.close();

                if(FileUtils.test(filePath, FileTest.EXISTS) == false) {
                    stderr.printf("Could not create settings file: %s\n", filePath);
                    Process.exit (1);
                }
            } catch (Error e) {
                stderr.printf("Could not create settings file: %s\n", e.message);
                Process.exit (1);
            }
        }

        Json.Parser parser = new Json.Parser ();
        try {
            if(!parser.load_from_file (filePath)) {
                stderr.printf ("Unable to parse `%s'\n", filePath);
                Process.exit (1);
            }
        } catch (Error e) {
            stderr.printf ("Unable to parse `%s': %s\n", filePath, e.message);
            Process.exit (1);
        }


        message("SettingsFile parsed.");

        // Get the root node:
        rootNode = parser.get_root ();
        if(rootNode.is_null ()) {
            stderr.printf ("Root node is null\n");
            Process.exit (1);
        }

        Json.Object rootObject = rootNode.get_object ();
        if(rootObject == null) {
            stderr.printf ("Root node is not an object\n");
            Process.exit (1);
        }

        message("Root Node OK");

        if(!rootObject.has_member ("feeds")) {
            feeds = new Json.Array ();
            var feeds_node = new Json.Node (Json.NodeType.ARRAY);
            feeds_node.set_array (feeds);
            rootObject.set_member ("feeds", feeds_node);
            message("Modified root object: feed array added");
        }
        else {
            message("Root object has feed array");
            feeds =  rootObject.get_array_member ("feeds");
        }

        if(feeds.get_length () == 0) {
            var feedNodeObject = new Json.Object();
            feedNodeObject.set_string_member ("name", "Reddit News");
            feedNodeObject.set_string_member ("uri", "https://www.reddit.com/r/news/.rss");

            var feedNode = new Json.Node (Json.NodeType.OBJECT);
            feedNode.set_object (feedNodeObject);
            feeds.add_element (feedNode);

            message("Feed added");
            updateSettings();
        }

        var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        add(layout);

        notebook = new Gtk.Notebook();
        notebook.set_tab_pos(Gtk.PositionType.TOP);
        notebook.set_scrollable(true);
        notebook.show_border = false;
        layout.pack_start(notebook, false);

        var feedBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
        feedBox.get_style_context().add_class("settings-page");
        notebook.append_page(feedBox, new Gtk.Label("Feeds"));

        var aboutBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
        notebook.append_page(aboutBox, new Gtk.Label("Weather"));
        layout.show_all ();

        var feedHeadline = new Gtk.Label("RSS Feeds");
        feedHeadline.get_style_context ().add_class ("text-size-normal");
        feedHeadline.get_style_context ().add_class ("fw-bold");
        feedHeadline.get_style_context().add_class("ps-4");
        feedHeadline.set_halign (Gtk.Align.START);
        feedBox.pack_start (feedHeadline, false);

        // add scrollwindow for feed list
        var feedScroll = new Gtk.ScrolledWindow (null, null);
        feedScroll.get_style_context().add_class("feed-list");
        feedScroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        feedScroll.vexpand = true;
        feedScroll.hexpand = true;

        var scrollLayout = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        feedScroll.add (scrollLayout);
        feedBox.pack_start (feedScroll, true);

        var addFeedButton = new Gtk.Button();
        var plusImage = new Gtk.Image.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        plusImage.pixel_size = 16;
        addFeedButton.set_image(plusImage);
        addFeedButton.set_halign (Gtk.Align.START);
        addFeedButton.clicked.connect(() => {
            var dialog = new FeedItemDialog(this);
            int response = dialog.run();
            if(response == Gtk.ResponseType.OK) {
                var feedName = dialog.get_feed_name();
                var feedUri = dialog.get_feed_uri();
                if(feedName.length > 0 && feedUri.length > 0) {
                    var feedNodeObject = new Json.Object();
                    feedNodeObject.set_string_member ("name", feedName);
                    feedNodeObject.set_string_member ("uri", feedUri);  
                    var feedNode = new Json.Node (Json.NodeType.OBJECT);
                    feedNode.set_object (feedNodeObject);
                    feeds.add_element (feedNode);   
                    message("Feed added");
                    updateSettings();
                    var feedRow = new FeedRow(this, feedUri, feedName);
                    scrollLayout.pack_start (feedRow, false);
                    scrollLayout.show_all ();
                }
            }
            dialog.destroy();
        });
        feedBox.pack_start (addFeedButton, false);

        for(int i = 0; i < feeds.get_length (); i++) {
            var feed = feeds.get_object_element (i);
            var feedRow = new FeedRow(this, feed.get_string_member ("uri"), feed.get_string_member ("name"));
            scrollLayout.pack_start (feedRow, false);
        }

        load_style_sheet();
        layout.show_all ();
    }

    private void updateSettings() {
        try {
            var generator = new Json.Generator ();
            generator.set_root (rootNode);
            generator.set_pretty (true);
            generator.to_file (filePath);
        } catch (Error e) {
            stderr.printf("Could not write settings file: %s\n", e.message);
            Process.exit (1);
        }
    }

    private void load_style_sheet() {
        var css = new Gtk.CssProvider();
        try {
            string css_path = PLUGIN_DIR + "/style.css";
            css.load_from_path(css_path);
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );
        } catch (Error e) {
            warning("Konnte CSS nicht laden: %s", e.message);
        }
    }

    private class FeedRow: Gtk.EventBox {
        private Gtk.Label label;
        private Gtk.Button deleteButton;
        private string feedName;
        private string uri;

        public FeedRow(SettingsWindow parentWindow, string u, string n) {
            Object();
            uri = u;
            feedName = n;

            set_visible_window(true); // sorgt dafür, dass EventBox Events empfängt
            set_above_child(true);    // Events gehen an die EventBox, nicht nur an die Kinder
            add_events(Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);

            var layout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            layout.get_style_context().add_class("feed-row");
            layout.get_style_context().add_class("ps-2");
            layout.set_sensitive(true);
            add(layout);

            enter_notify_event.connect(() => {
                layout.get_style_context().add_class("hover");
                return true;
            });
            leave_notify_event.connect(() => {
                layout.get_style_context().remove_class("hover");
                return true;
            });

            label = new Gtk.Label(feedName);
            label.get_style_context ().add_class ("text-size-small");
            label.set_halign (Gtk.Align.START);
            layout.pack_start(label, true);

            deleteButton = new Gtk.Button();
            deleteButton.set_size_request(16, 16);
            deleteButton.get_style_context().add_class("p-0");

            var deleteImage = new Gtk.Image();
            deleteImage.set_from_icon_name("edit-delete-symbolic", Gtk.IconSize.BUTTON);
            deleteImage.pixel_size = 16;
            deleteImage.vexpand = false;
            deleteImage.hexpand = false;
            deleteButton.set_image(deleteImage);

            deleteButton.clicked.connect(() => {
                // remove this row from parent
                var parent = get_parent();
                if(parent != null) {
                    parent.remove(this);
                    for(int i = 0; i < parentWindow.feeds.get_length(); i++) {
                        var feed = parentWindow.feeds.get_object_element (i);
                        if(feed.get_string_member ("uri") == uri && feed.get_string_member ("name") == feedName) {
                            parentWindow.feeds.remove_element (i);
                            parentWindow.updateSettings();
                            message("Feed removed");
                            break;  
                        }
                    }

                }
            });
            layout.pack_start(deleteButton, false);
        }
    }

    private class FeedItemDialog: Gtk.Dialog {
        private Gtk.Entry nameEntry;
        private Gtk.Entry uriEntry;

        public FeedItemDialog(Gtk.Window parent) {
            Object();
            get_style_context().add_class("settings-dialog");
            load_style_sheet();
            set_transient_for(parent);
            set_title("Feed Item");
            set_type_hint(Gdk.WindowTypeHint.DIALOG);
            gravity = Gdk.Gravity.CENTER;
            set_default_size (400, 200);

            var contentArea = get_content_area();
            var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
            layout.set_margin_top (10);
            layout.set_margin_bottom (10);
            layout.set_margin_start (10);
            layout.set_margin_end (10);
            contentArea.add(layout);

            var nameLabel = new Gtk.Label("Name:");
            nameLabel.set_halign (Gtk.Align.START);
            layout.pack_start(nameLabel, false);

            nameEntry = new Gtk.Entry();
            layout.pack_start(nameEntry, false);

            var nameErrorLabel = new Gtk.Label("Please enter a name");
            nameErrorLabel.get_style_context ().add_class ("text-danger");
            nameErrorLabel.set_halign (Gtk.Align.START);
            nameErrorLabel.hide();
            layout.pack_start(nameErrorLabel, false);

            var uriLabel = new Gtk.Label("URI:");
            uriLabel.set_halign (Gtk.Align.START);
            layout.pack_start(uriLabel, false);

            uriEntry = new Gtk.Entry();
            layout.pack_start(uriEntry, false);

            var uriErrorLabel = new Gtk.Label("Please enter a valid uri (http:// or https://)");
            uriErrorLabel.get_style_context ().add_class ("text-danger");
            uriErrorLabel.set_halign (Gtk.Align.START);
            uriErrorLabel.hide();
            layout.pack_start(uriErrorLabel, false);

            var buttonBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            layout.pack_end (buttonBox, false, false, 0);

            var cancelButton = new Gtk.Button.with_label(_("Cancel"));
            buttonBox.pack_end (cancelButton, false, false, 0);

            var okButton = new Gtk.Button.with_label (_("OK"));
            okButton.set_can_default (true);
            okButton.grab_default ();
            buttonBox.pack_end (okButton, false, false, 0);

            cancelButton.clicked.connect(() => {
                response(Gtk.ResponseType.CANCEL);
            });

            okButton.clicked.connect((e) => {
                nameErrorLabel.set_visible(false);
                uriErrorLabel.set_visible(false);
                layout.queue_resize();

                var name = nameEntry.get_text().chomp();
                var uri = uriEntry.get_text();

                if(name.length == 0) {
                    nameErrorLabel.set_visible(true);
                    layout.queue_resize();
                    return;
                }

                if(!isValidUrl(uri)) {
                    uriErrorLabel.set_visible(true);
                    layout.queue_resize();
                    return;
                }

                // TODO request HEAD for content type negotiation

                response(Gtk.ResponseType.OK);
            });

            show_all();
            nameErrorLabel.hide();
            uriErrorLabel.hide();
        }

        public string get_feed_name() {
            return nameEntry.get_text();
        }

        public string get_feed_uri() {
            return uriEntry.get_text();
        }

        private void load_style_sheet() {
            var css = new Gtk.CssProvider();
            try {
                string css_path = PLUGIN_DIR + "/style.css";
                css.load_from_path(css_path);
                Gtk.StyleContext.add_provider_for_screen(
                    Gdk.Screen.get_default(),
                    css,
                    Gtk.STYLE_PROVIDER_PRIORITY_USER
                );
            } catch (Error e) {
                warning("Konnte CSS nicht laden: %s", e.message);
            }
        }

        public static bool isValidUrl(string url) {
            // Prüfen, ob die URL http:// oder https:// beginnt
            if (!url.has_prefix("http://") && !url.has_prefix("https://")) {
                return false;
            }

            try {
                var uri = Uri.parse(url, GLib.UriFlags.PARSE_RELAXED);
                
                // Prüfen, ob Host gesetzt ist
                if (uri.get_host() == null || uri.get_host().length == 0) {
                    return false;
                }

                return true;
            } catch (Error e) {
                // Uri Konstruktor wirft, wenn ungültig
                return false;
            }
        }
    }
}