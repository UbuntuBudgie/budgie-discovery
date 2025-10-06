public class LocationLayoutItem: Gtk.EventBox {
            private Gtk.Box textLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            private LocationItem data;
            public signal void selected();

            public void setSelected(bool value) {
                if(!value) {
                    textLayout.get_style_context().remove_class("selected");
                } else {
                    textLayout.get_style_context().add_class("selected");
                }
            }

            public LocationItem getLocation() {
                return data;
            }

            public LocationLayoutItem(LocationItem item) {
                Object();
                data = item;

                textLayout.get_style_context().add_class("list-item");
                textLayout.get_style_context().add_class("pt-2");
                textLayout.get_style_context().add_class("pb-2");
                textLayout.get_style_context().add_class("ps-3");
                textLayout.get_style_context().add_class("pe-3");
                add(textLayout);

                string name = item.name;
                var nameLabel = new Gtk.Label(null);
                nameLabel.halign = Gtk.Align.START;
                nameLabel.valign = Gtk.Align.END;
                nameLabel.set_text(name);
                nameLabel.set_use_markup(false);
                textLayout.pack_start(nameLabel, false);

                var description = item.getDescription();
                if (description.length > 0) {
                    var descriptionLabel = new Gtk.Label(null);
                    descriptionLabel.halign = Gtk.Align.START;
                    descriptionLabel.yalign = -5.0f;
                    descriptionLabel.valign = Gtk.Align.START;
                    descriptionLabel.get_style_context().add_class("text-size-small");
                    descriptionLabel.get_style_context().add_class("text-secondary");
                    descriptionLabel.get_style_context().add_class("font-italic");
                    descriptionLabel.set_text(description);
                    descriptionLabel.set_use_markup(false);
                    textLayout.pack_start(descriptionLabel, false);
                }

                add_events(Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK | Gdk.EventMask.BUTTON_PRESS_MASK);
                this.enter_notify_event.connect(() => {
                    if(!textLayout.get_style_context().has_class("selected"))
                        textLayout.get_style_context().add_class("hover");
                    return true;
                });
                this.leave_notify_event.connect(() => {
                    textLayout.get_style_context().remove_class("hover");
                    return true;
                });
                this.button_press_event.connect(() => {
                    this.setSelected(true);
                    textLayout.get_style_context().remove_class("hover");
                    selected();
                    return true;
                });
            }
        }