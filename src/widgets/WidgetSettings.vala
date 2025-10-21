using Config;

public class WidgetSettings: Gtk.Box {
    private Gtk.Box widgetListLayout;
    private Gtk.Overlay overlay;
    private WeatherItemDialog dialogLayer;
    private SettingsService settings;
    private Json.Array weatherLocations;

    public WidgetSettings() {
        Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

        settings = SettingsService.getInstance();
        overlay = new Gtk.Overlay();
        pack_start(overlay, true, true, 0);

        var contentBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        overlay.add(contentBox);

        var widgetListScrollable = new Gtk.ScrolledWindow (null, null);
        widgetListScrollable.get_style_context().add_class("feed-list");
        widgetListScrollable.get_style_context().add_class("frame");
        widgetListScrollable.get_style_context().add_class("mb-2");
        widgetListScrollable.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        widgetListScrollable.vexpand = true;
        widgetListScrollable.hexpand = true;

        widgetListLayout = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        widgetListScrollable.add (widgetListLayout);
        contentBox.pack_start (widgetListScrollable, true);

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

            dialogLayer = new WeatherItemDialog();
            

            dialogLayer.ok_button_pressed.connect((dialog) => {
                var location = dialogLayer.getLocation();
                if(location != null) {
                    var layoutItem = new WeatherListItem();
                    layoutItem.setData(location);
                    layoutItem.setPrimaryText(location.name);
                    layoutItem.setSecondaryText(location.getDescription());
                    layoutItem.setSelectable(false);
                    widgetListLayout.pack_start(layoutItem, false);
                    widgetListLayout.show_all();

                    // Save Settings
                    var weatherNode = settings.get_value("weather");
                    if(weatherNode == null) {
                        weatherNode = new Json.Node(Json.NodeType.OBJECT);
                        weatherNode.set_object(new Json.Object());
                    }

                    var locationNode = new Json.Object();
                    locationNode.set_string_member("name", location.name);
                    locationNode.set_string_member("country", location.country);
                    locationNode.set_double_member("latitude", location.latitude);
                    locationNode.set_double_member("longitude", location.longitude);
                    locationNode.set_string_member("admin1", location.admin1);
                    locationNode.set_string_member("admin2", location.admin2);
                    locationNode.set_string_member("admin3", location.admin3);
                    locationNode.set_string_member("admin4", location.admin4);

                    weatherLocations.add_object_element(locationNode);
                    weatherNode.get_object().set_array_member("locations", weatherLocations);
                    settings.set_value("weather", weatherNode);

                    loadLocations();
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

        this.map.connect(() => {
            get_style_context().add_class("settings-page");
            if (overlay.get_parent() == null)
                pack_start(overlay, true, true, 0);
            loadLocations();
        });

        this.unmap.connect(() => {
            destroyDialog();
        });
    }

    private void loadLocations() {
        Idle.add(() => {
            settings = SettingsService.getInstance();
            var weatherNode = settings.get_value("weather");
            if (weatherNode == null || weatherNode.get_node_type() != Json.NodeType.OBJECT) {
                weatherNode = new Json.Node(Json.NodeType.OBJECT);
                weatherNode.set_object(new Json.Object());
            }
            
            if(!weatherNode.get_object().has_member("locations")) {
                weatherLocations = new Json.Array();
                weatherNode.get_object().set_array_member("locations", weatherLocations);
            } else {
                weatherLocations = weatherNode.get_object().get_array_member("locations");
            }

            widgetListLayout.forall((child) => {
                widgetListLayout.remove(child);
                child = null;
            });
                
            weatherLocations.foreach_element((element, index) => {
                var record = element.get_object_element(index);
                var name = record.get_string_member("name");
                var country = record.get_string_member("country");
                var latitude = record.get_double_member("latitude");
                var longitude = record.get_double_member("longitude");
                var admin1 = record.has_member("admin1") ? record.get_string_member("admin1") : null;
                var admin2 = record.has_member("admin2") ? record.get_string_member("admin2") : null;
                var admin3 = record.has_member("admin3") ? record.get_string_member("admin3") : null;
                var admin4 = record.has_member("admin4") ? record.get_string_member("admin4") : null;

                var location1 = new LocationItem();
                location1.name = name;
                location1.country = country;
                location1.latitude = latitude;
                location1.longitude = longitude;
                location1.admin1 = admin1;
                location1.admin2 = admin2;
                location1.admin3 = admin3;
                location1.admin4 = admin4;

                var layoutItem1 = new WeatherListItem();
                layoutItem1.setData(location1);
                layoutItem1.setPrimaryText(location1.name);
                layoutItem1.setSecondaryText(location1.getDescription());
                layoutItem1.setSelectable(false);
                widgetListLayout.pack_start(layoutItem1, false);
            });
            widgetListLayout.show_all();
            
            return false;
        }, Priority.DEFAULT);
    }

    private void destroyDialog() {
        if(dialogLayer != null) {
            overlay.remove(dialogLayer);
            dialogLayer.destroy();
            dialogLayer = null;
            overlay.queue_draw();
        }
    }

    private class WeatherListItem: ListItem {
        private Gtk.Button deleteButton = new Gtk.Button();

        public WeatherListItem() {
            base();
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
                var weatherNode = settings.get_value("weather");
                if(weatherNode == null) {
                    weatherNode = new Json.Node(Json.NodeType.OBJECT);
                    weatherNode.set_object(new Json.Object());
                }
                
                var weatherNodeObject = weatherNode.get_object();
                var weatherLocations = weatherNodeObject.has_member("locations") ? weatherNodeObject.get_array_member("locations") : new Json.Array();
                var index = get_parent().get_children().index(this);
                if(index >= 0) {
                    weatherLocations.remove_element(index);
                }

                weatherNode.get_object().set_array_member("locations", weatherLocations);
                settings.set_value("weather", weatherNode);
                get_parent().remove(this);
                return true;
            });
            addActionButton(deleteButton);
        }
    }

    private class WeatherItemDialog: OverlayDialog {
        private Gtk.ScrolledWindow scrollArea;
        private Gtk.Entry nameEntry;
        private Gee.ArrayList<LocationItem> locations = new Gee.ArrayList<LocationItem>();
        public Gtk.Box locationLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        private static string OPEN_METEO_SEARCH_URL = "https://geocoding-api.open-meteo.com/v1/search?name=%s&count=10&language=%s";
        private LocationItem selectedLocation;

        public signal void configured();

        public LocationItem getLocation() {
            return selectedLocation;
        }

        public WeatherItemDialog() {
            base();
            setTitle(_("Add Location"));

            var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            layout.vexpand = true;
            layout.hexpand = true;
            getContentArea().pack_start(layout, true);

            var nameLabel = new Gtk.Label("%s:".printf(_("Location")));
            nameLabel.set_halign (Gtk.Align.START);
            nameLabel.margin_bottom = 5;
            layout.pack_start(nameLabel, false);

            nameEntry = new Gtk.Entry();
            var searchButton = new Gtk.Button.from_icon_name("search-symbolic", Gtk.IconSize.BUTTON);
            var searchBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            searchBox.pack_start(nameEntry, true, true);
            searchBox.pack_start(searchButton, false);
            searchBox.margin_bottom = 10;
            layout.pack_start(searchBox, false, true);

            scrollArea = new Gtk.ScrolledWindow(null, null);
            scrollArea.overlay_scrolling = false;
            scrollArea.border_width = 0;
            scrollArea.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scrollArea.vexpand = true;
            scrollArea.hexpand = true;
            scrollArea.get_style_context().add_class("feed-list");
            scrollArea.add(locationLayout);
            scrollArea.set_no_show_all(true);
            scrollArea.set_size_request(-1, 200);
            layout.pack_start(scrollArea, true);

            var nameErrorLabel = new Gtk.Label("Please enter a location name");
            nameErrorLabel.get_style_context ().add_class ("text-danger");
            nameErrorLabel.set_halign (Gtk.Align.START);
            nameErrorLabel.set_no_show_all(true);
            nameErrorLabel.hide();
            layout.pack_start(nameErrorLabel, false);

            okButton.set_sensitive(false);

            searchButton.clicked.connect(() => {
                Idle.add(() => {
                    GLib.MainContext.@default().invoke(() => {
                        searchLocation();
                        return false;
                    }, Priority.DEFAULT);
                    return false;
                });
            });

            map.connect(() => {
                locations.clear();
                locationLayout.foreach((child) => {
                    locationLayout.remove(child);
                });
            });

            layout.show_all();
            scrollArea.hide();
        }

        private void searchLocation() {
            selectedLocation = null;
            okButton.set_sensitive(false);
            scrollArea.hide();

            string searchText = nameEntry.get_text().chomp();
            if (searchText.length == 0) return;

            string? locale = Intl.setlocale (LocaleCategory.ALL, "");
            if (locale == null)
                locale = "C";

            string[] parts = locale.split ("_");

            string lang = parts.length > 0 ? parts[0] : "en";
            string url = OPEN_METEO_SEARCH_URL.printf(searchText, lang);

            var session = new Soup.Session();
            var msg = new Soup.Message("GET", url);

            try {
                var response = session.send_and_read (msg, null);
                if (msg.status_code != 200) {
                    warning ("HTTP-Fehler: %d", msg.get_status ());
                    return;
                }

                // Lies den Body als UTF-8-Text
                var data_stream = new GLib.MemoryInputStream.from_bytes (response);
                var dis = new GLib.DataInputStream (data_stream);
                string? data = dis.read_upto ("", 0, null); // liest gesamten Stream

                if (data == null)
                    data = "";

                var parser = new Json.Parser();
                parser.load_from_data(data, data.length);

                var root = parser.get_root();
                var rootObject = root.get_object();
                if (root != null && rootObject.has_member("results")) {
                    var results = rootObject.get_array_member("results");

                    locationLayout.foreach(child => {
                        locationLayout.remove(child);
                        child = null;
                    });

                    locations.clear();

                    results.foreach_element((element, index) => {
                        var resultNode = element.get_object_element(index);
                        LocationItem item = new LocationItem();
                        item.name = resultNode.get_string_member("name");
                        item.country = resultNode.get_string_member("country");
                        item.admin1 = resultNode.has_member("admin1") ? resultNode.get_string_member("admin1") : null;
                        item.admin2 = resultNode.has_member("admin2") ? resultNode.get_string_member("admin2") : null;
                        item.admin3 = resultNode.has_member("admin3") ? resultNode.get_string_member("admin3") : null;
                        item.admin4 = resultNode.has_member("admin4") ? resultNode.get_string_member("admin4") : null;
                        item.latitude = resultNode.has_member("latitude") ? resultNode.get_double_member("latitude") : 0;
                        item.longitude = resultNode.has_member("longitude") ? resultNode.get_double_member("longitude") : 0;
                        locations.add(item);

                        var layoutItem = new ListItem();
                        layoutItem.setData(item);
                        layoutItem.setPrimaryText(item.name);
                        layoutItem.setSecondaryText(item.getDescription());
                        layoutItem.valign = Gtk.Align.START;
                        locationLayout.pack_start(layoutItem, false, false);

                        layoutItem.selected.connect(() => {
                            locationLayout.get_children().foreach(child => {
                                if(child is ListItem && child != layoutItem) {
                                    ((ListItem)child).setSelected(false);
                                }
                            });
                            selectedLocation = (LocationItem) layoutItem.getData();
                            okButton.set_sensitive(true);
                            okButton.grab_focus();
                        });

                        if((index + 1) < results.get_length()) {
                            var divider = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
                            divider.get_style_context().add_class ("border-bottom");
                            divider.margin_bottom = 1;
                            divider.margin_top = 1;
                            divider.valign = Gtk.Align.START;
                            locationLayout.pack_start(divider, false);
                        }
                    });
                    if(results.get_length() > 0) {
                        locationLayout.show_all();
                        scrollArea.show();
                    }
                }

            } catch (Error e) {
                warning("Fehler beim Abrufen der Daten: %s", e.message);
            }
        }
    }
}