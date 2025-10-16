using Config;

public class FeedSettings: Gtk.Box {
    private static Gtk.Box feedLayout;
    private FeedItemDialog dialogLayer;
    private Gtk.Overlay overlay;
    
    public FeedSettings() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        get_style_context().add_class("settings-page");

        overlay = new Gtk.Overlay();
        pack_start(overlay, true, true, 0);

        var contentBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        overlay.add(contentBox);

        var feedScroll = new Gtk.ScrolledWindow (null, null);
        feedScroll.get_style_context().add_class("feed-list");
        feedScroll.get_style_context().add_class("mb-2");
        feedScroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        feedScroll.vexpand = true;
        feedScroll.hexpand = true;

        feedLayout = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        feedScroll.add (feedLayout);
        contentBox.pack_start (feedScroll, true);

        var plusButton = new Gtk.Button();
        var plusImage = new Gtk.Image.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        plusImage.pixel_size = 16;
        plusButton.set_image(plusImage);
        plusButton.set_label(_("Add"));
        plusButton.set_halign (Gtk.Align.START);
        plusButton.set_always_show_image(true);
        plusButton.get_style_context().add_class("flat");
        plusButton.clicked.connect(() => {
            if (dialogLayer != null) {
                dialogLayer.destroy();
            }

            dialogLayer = new FeedItemDialog(this);

            dialogLayer.configured.connect((dialog) => {
                var feedName = dialogLayer.get_feed_name();
                var feedUri = dialogLayer.get_feed_uri();
                if(feedName.length > 0 && feedUri.length > 0) {
                    var feedNodeObject = new Json.Object();
                    feedNodeObject.set_string_member ("name", feedName);
                    feedNodeObject.set_string_member ("uri", feedUri);
                    
                    var digest = new Checksum(ChecksumType.MD5);
                    digest.update(feedUri.data, feedUri.length);
                    feedNodeObject.set_string_member("uid", digest.get_string());

                    var settings = SettingsService.getInstance();
                    var feeds = settings.get_value("feeds");
                    if(feeds == null) {
                        feeds = new Json.Node(Json.NodeType.ARRAY);
                        var feedArray = new Json.Array();
                        feeds.set_array(feedArray);
                    }
                    feeds.get_array().add_object_element(feedNodeObject);
                    settings.set_value("feeds", feeds);

                    var feedRow = new FeedRow(digest.get_string(), feedUri, feedName);
                    feedLayout.pack_start (feedRow, false);
                    feedLayout.show_all ();
                }
                destroyDialog();
            });

            dialogLayer.cancel_button_pressed.connect(() => {
                destroyDialog();
            });

            GLib.Idle.add(() => {
                overlay.add_overlay(dialogLayer);
                overlay.show_all();
                return false;
            });
        });
        contentBox.pack_start (plusButton, false);

        map.connect(() => {
            loadFeeds();
        });
        load_style_sheet();
    }

    private void destroyDialog() {
        if(dialogLayer != null) {
            overlay.remove(dialogLayer);
            dialogLayer.destroy();
            dialogLayer = null;
            overlay.queue_draw();
        }
    }

    private void loadFeeds() {
        var settings = SettingsService.getInstance();
        var feeds = settings.get_value("feeds");
        if(feeds == null) {
            feeds = new Json.Node(Json.NodeType.ARRAY);
            var feedArray = new Json.Array();
            feeds.set_array(feedArray);
        }

        feedLayout.foreach((child) => {
            feedLayout.remove(child);
            child.destroy();
            child = null;
        });

        for(int i = 0; i < feeds.get_array().get_length (); i++) {
            var feed = feeds.get_array().get_object_element (i);
            var feedRow = new FeedRow(feed.get_string_member("uid"), feed.get_string_member ("uri"), feed.get_string_member ("name"));
            feedLayout.pack_start (feedRow, false);
        }
    }

    private class FeedRow: ListItem {
        private Gtk.Button deleteButton;
        private string feedName;
        private string feedUri;
        private string feedUid;

        public signal void onFeedDelete(string uid);

        public FeedRow(string? uid, string? uri, string? name) {
            base();
            feedUri = uri;
            feedName = name;
            feedUid = uid;

            setSelectable(false);
            setPrimaryText(feedName);
            setSecondaryText(uri);

            deleteButton = new Gtk.Button();
            deleteButton.set_size_request(16, 16);
            deleteButton.get_style_context().add_class("p-0");
            deleteButton.get_style_context().add_class("m-0");
            deleteButton.get_style_context().add_class("flat");
            deleteButton.get_style_context().add_class("no-background");

            var deleteImage = new Gtk.Image();
            deleteImage.set_from_icon_name("edit-delete-symbolic", Gtk.IconSize.BUTTON);
            deleteImage.pixel_size = 16;
            deleteImage.vexpand = false;
            deleteImage.hexpand = false;
            deleteButton.set_image(deleteImage);

            deleteButton.button_press_event.connect(() => {
                var settings = SettingsService.getInstance();
                var feeds = settings.get_value("feeds");
                if(feeds == null) {
                    feeds = new Json.Node(Json.NodeType.ARRAY);
                    var feedArray = new Json.Array();
                    feeds.set_array(feedArray);
                }

                int index = 0;
                feeds.get_array().foreach_element((feed) => {
                    var objectNode = feed.get_object_element(index);
                    if(objectNode.get_string_member("uid") == uid) {
                        feeds.get_array().remove_element(index);
                    }
                    index++;
                });
                settings.set_value("feeds", feeds);
                get_parent().remove(this);
                return true;
            });
            addActionButton(deleteButton);
        }
    }

    private class FeedItemDialog: OverlayDialog {
        private Gtk.Entry nameEntry;
        private Gtk.Entry uriEntry;

        public signal void configured();

        public FeedItemDialog(FeedSettings parent) {
            base();
            setTitle(_("Add Feed"));

            var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            layout.vexpand = true;
            layout.hexpand = true;
            getContentArea().pack_start(layout, true);

            var nameLabel = new Gtk.Label("Name:");
            nameLabel.set_halign (Gtk.Align.START);
            nameLabel.margin_bottom = 5;
            layout.pack_start(nameLabel, false);

            nameEntry = new Gtk.Entry();
            layout.pack_start(nameEntry, false);

            var nameErrorLabel = new Gtk.Label("Please enter a name");
            nameErrorLabel.get_style_context ().add_class ("text-danger");
            nameErrorLabel.get_style_context ().add_class ("text-size-small");
            nameErrorLabel.set_halign (Gtk.Align.START);
            nameErrorLabel.margin_top = 5;
            nameErrorLabel.set_no_show_all(true);
            nameErrorLabel.hide();
            layout.pack_start(nameErrorLabel, false);

            var uriLabel = new Gtk.Label("URI:");
            uriLabel.set_halign (Gtk.Align.START);
            uriLabel.margin_top = 15;
            uriLabel.margin_bottom = 5;
            layout.pack_start(uriLabel, false);

            uriEntry = new Gtk.Entry();
            layout.pack_start(uriEntry, false);

            var uriErrorLabel = new Gtk.Label("Please enter a valid uri (http:// or https://)");
            uriErrorLabel.get_style_context ().add_class ("text-danger");
            uriErrorLabel.get_style_context ().add_class ("text-size-small");
            uriErrorLabel.set_halign (Gtk.Align.START);
            uriErrorLabel.margin_top = 5;
            uriErrorLabel.set_no_show_all(true);
            uriErrorLabel.hide();
            layout.pack_start(uriErrorLabel, false);

            ok_button_pressed.connect((e) => {
                nameErrorLabel.set_visible(false);
                uriErrorLabel.set_visible(false);
                queue_resize();

                var name = nameEntry.get_text().chomp();
                var uri = uriEntry.get_text();

                if(name.length == 0) {
                    nameErrorLabel.set_visible(true);
                    queue_resize();
                    return;
                }

                if(!isValidUrl(uri)) {
                    uriErrorLabel.set_visible(true);
                    queue_resize();
                    return;
                }

                configured();
            });

            layout.show_all();
            nameErrorLabel.hide();
            uriErrorLabel.hide();
        }

        public string get_feed_name() {
            return nameEntry.get_text();
        }

        public string get_feed_uri() {
            return uriEntry.get_text();
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
}