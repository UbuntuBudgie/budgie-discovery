using Config;

public class WidgetSettings: Gtk.Box {
    private Gtk.Box widgetListLayout;

    public WidgetSettings(Gtk.Window window) {
        set_orientation(Gtk.Orientation.VERTICAL);
        get_style_context().add_class("settings-page");

        var widgetListScrollable = new Gtk.ScrolledWindow (null, null);
        widgetListScrollable.get_style_context().add_class("feed-list");
        widgetListScrollable.get_style_context().add_class("mb-2");
        widgetListScrollable.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        widgetListScrollable.vexpand = true;
        widgetListScrollable.hexpand = true;

        widgetListLayout = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        widgetListScrollable.add (widgetListLayout);
        pack_start (widgetListScrollable, true);

        var plusButton = new Gtk.Button();
        var plusImage = new Gtk.Image.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        plusImage.pixel_size = 16;
        plusButton.set_image(plusImage);
        plusButton.set_label(_("Add"));
        plusButton.set_halign (Gtk.Align.START);
        plusButton.set_always_show_image(true);
        plusButton.get_style_context().add_class("border-1");
        plusButton.clicked.connect(() => {
            var dialog = new WeatherItemDialog(window, this);
            int response = dialog.run();
            if(response == Gtk.ResponseType.OK) {
            }
            dialog.destroy();
        });
        pack_start (plusButton, false);
    }

    private class WeatherItemDialog: Gtk.Dialog {
        private Gtk.Entry nameEntry;
        private Gee.ArrayList<LocationItem> locations;
        private Gtk.Box locationLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        private static string OPEN_METEO_SEARCH_URL = "https://geocoding-api.open-meteo.com/v1/search?name=%s&count=10&language=en";

        public WeatherItemDialog(Gtk.Window window, WidgetSettings parent) {
            Object();
            get_style_context().add_class("settings-dialog");
            load_style_sheet();
            set_transient_for(window);
            set_type_hint(Gdk.WindowTypeHint.DIALOG);
            gravity = Gdk.Gravity.CENTER;
            set_default_size (400, 280);
            set_title(_("Add Weather Location"));

            locations = new Gee.ArrayList<LocationItem>();

            var contentArea = get_content_area();
            var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
            layout.set_margin_top (10);
            layout.set_margin_bottom (10);
            layout.set_margin_start (10);
            layout.set_margin_end (10);
            layout.vexpand = true;
            contentArea.get_style_context().add_class("no-border");
            contentArea.add(layout);

            var nameLabel = new Gtk.Label("Location:");
            nameLabel.set_halign (Gtk.Align.START);
            layout.pack_start(nameLabel, false);

            nameEntry = new Gtk.Entry();
            var searchButton = new Gtk.Button.from_icon_name("search-symbolic", Gtk.IconSize.BUTTON);
            var searchBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            searchBox.pack_start(nameEntry, true, true);
            searchBox.pack_start(searchButton, false);
            layout.pack_start(searchBox, false, true);

            var scrollArea = new Gtk.ScrolledWindow(null, null);
            scrollArea.overlay_scrolling = false;
            scrollArea.border_width = 0;
            scrollArea.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scrollArea.vexpand = true;
            scrollArea.hexpand = true;
            scrollArea.get_style_context().add_class("feed-list");
            scrollArea.add(locationLayout);
            layout.pack_start(scrollArea, true);

            var nameErrorLabel = new Gtk.Label("Please enter a location name");
            nameErrorLabel.get_style_context ().add_class ("text-danger");
            nameErrorLabel.set_halign (Gtk.Align.START);
            nameErrorLabel.set_no_show_all(true);
            nameErrorLabel.hide();
            layout.pack_start(nameErrorLabel, false);

            var buttonBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            layout.pack_end (buttonBox, false, false, 0);

            var okButton = new Gtk.Button.with_label (_("OK"));
            okButton.set_can_default (true);
            okButton.grab_default ();
            okButton.set_sensitive(false);
            buttonBox.pack_end (okButton, false, false, 0);

            var cancelButton = new Gtk.Button.with_label(_("Cancel"));
            buttonBox.pack_end (cancelButton, false, false, 0);

            cancelButton.clicked.connect(() => {
                response(Gtk.ResponseType.CANCEL);
            });

            okButton.clicked.connect((e) => {
                
                response(Gtk.ResponseType.OK);
            });

            map.connect(() => {
                locations.clear();
                    locationLayout.foreach((child) => {
                        locationLayout.remove(child);
                    });
            });

            searchButton.clicked.connect(() => {
                Idle.add(() => {
                    searchLocation();
                    return false;
                }, 0);
            });
            layout.show_all();
        }

        private void searchLocation() {
            string searchText = nameEntry.get_text().chomp();
            if (searchText.length == 0) return;

            string url = OPEN_METEO_SEARCH_URL.printf(searchText);

            var session = new Soup.Session();
            var msg = new Soup.Message("GET", url);

            try {
                var responseData = session.send_and_read(msg, null);
                if (msg.status_code != 200) {
                    warning("HTTP-Fehler: %d", msg.get_status());
                    return;
                }

                var contentType = msg.get_response_headers().get_content_type(null);
                message(contentType);
                // TODO check for json

                uint8[] bytes = responseData.get_data().copy();
                string data = (string) bytes;

                var parser = new Json.Parser();
                parser.load_from_data(data, data.length);

                var root = parser.get_root()?.get_object();
                if (root != null && root.has_member("results")) {
                    var results = root.get_array_member("results");

                    // Alte Einträge löschen
                    locationLayout.foreach(child => {
                        locationLayout.remove(child);
                        child = null;
                    });

                    locations.clear();

                    Gtk.RadioButton? radioGroup = null;
                    results.foreach_element((element, index) => {
                        var resultNode = element.get_object_element(index);
                        LocationItem item = new LocationItem();
                        item.name = resultNode.get_string_member("name");
                        item.country = resultNode.get_string_member("country");
                        item.admin1 = resultNode.has_member("admin1") ? resultNode.get_string_member("admin1") : null;
                        item.admin2 = resultNode.has_member("admin2") ? resultNode.get_string_member("admin2") : null;
                        item.admin3 = resultNode.has_member("admin3") ? resultNode.get_string_member("admin3") : null;
                        item.admin4 = resultNode.has_member("admin4") ? resultNode.get_string_member("admin4") : null;
                        locations.add(item);

                        var layoutItem = new LocationLayoutItem(item, radioGroup);
                        if (radioGroup == null)
                            radioGroup = layoutItem.getRadio();
                        layoutItem.valign = Gtk.Align.START;
                        locationLayout.pack_start(layoutItem, false, false);

                        if((index + 1) < results.get_length()) {
                            var divider = new Gtk.Separator(Gtk.Orientation.VERTICAL);
                            divider.get_style_context().add_class ("border-bottom");
                            divider.valign = Gtk.Align.START;
                            locationLayout.pack_start(divider, false);
                        }

                        layoutItem.selectionChanged.connect(() => {
                            locationLayout.foreach(child => {
                                if(child is LocationLayoutItem && layoutItem != child) {
                                    ((LocationLayoutItem)child).setSelected(false);
                                }
                            });
                        });
                    });

                    show_all();
                }

            } catch (Error e) {
                warning("Fehler beim Abrufen der Daten: %s", e.message);
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

        private class LocationLayoutItem: Gtk.Box {
            private Gtk.RadioButton radio;

            public signal void selectionChanged();

            public void setSelected(bool value) {
                radio.set_active(value);
                get_style_context().remove_class("selected");    
            }

            public Gtk.RadioButton getRadio() {
                return radio;
            }

            public LocationLayoutItem(LocationItem item, Gtk.RadioButton? group) {
                Object();
                set_orientation(Gtk.Orientation.HORIZONTAL);
                set_spacing(10);
                get_style_context().add_class("list-item");

                var admins = new Gee.ArrayList<string>();
                if (item.country != null && item.country.length > 0)
                    admins.add(item.country);

                if (item.admin1 != null && item.admin1.length > 0)
                    admins.add(item.admin1);

                if (item.admin2 != null && item.admin2.length > 0)
                    admins.add(item.admin2);

                if (item.admin3 != null && item.admin3.length > 0)
                    admins.add(item.admin3);

                if (item.admin4 != null && item.admin4.length > 0)
                    admins.add(item.admin4);

                // UTF-8 Strings direkt verbinden
                string admin_text = "";
                bool first = true;
                foreach (var a in admins) {
                    if (first) {
                        admin_text += a;
                        first = false;
                    } else {
                        admin_text += ", " + a;
                    }
                }

                radio = (group == null)
                    ? new Gtk.RadioButton(null)
                    : new Gtk.RadioButton.from_widget(group);
                pack_start(radio, false);

                var textLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
                textLayout.get_style_context().add_class("pt-2");
                textLayout.get_style_context().add_class("pb-2");
                textLayout.get_style_context().add_class("ps-3");
                textLayout.get_style_context().add_class("pe-3");
                pack_start(textLayout, false);

                string name = item.name;
                var nameLabel = new Gtk.Label(null);
                nameLabel.halign = Gtk.Align.START;
                nameLabel.valign = Gtk.Align.END;
                nameLabel.set_text(name);
                nameLabel.set_use_markup(false);
                textLayout.pack_start(nameLabel, false);

                if (admin_text.length > 0) {
                    var descriptionLabel = new Gtk.Label(null);
                    descriptionLabel.halign = Gtk.Align.START;
                    descriptionLabel.yalign = -5.0f;
                    descriptionLabel.valign = Gtk.Align.START;
                    descriptionLabel.get_style_context().add_class("text-size-small");
                    descriptionLabel.get_style_context().add_class("text-secondary");
                    descriptionLabel.get_style_context().add_class("font-italic");
                    descriptionLabel.set_text(admin_text);
                    descriptionLabel.set_use_markup(false);
                    textLayout.pack_start(descriptionLabel, false);
                }

                radio.set_size_request(24, 24);
                radio.toggled.connect(() => {
                    get_style_context().add_class("selected");
                    selectionChanged();
                });
            }
        }
    }

    private class LocationItem {
        public string? name {get; set;}
        public string? country {get; set;}
        public string? admin1 {get; set;}
        public string? admin2 {get; set;}
        public string? admin3 {get; set;}
        public string? admin4 {get; set;}
    }
}