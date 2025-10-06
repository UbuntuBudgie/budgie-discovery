public class ListItem: Gtk.EventBox {
            private Gtk.Box textLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            private Object data;
            private Gtk.Label primaryLabel = new Gtk.Label(null);
            private Gtk.Label secondaryLabel = new Gtk.Label(null);

            private string? primaryText;
            private string? secondaryText;

            public signal void selected();

            public void setSelected(bool value) {
                if(!value) {
                    textLayout.get_style_context().remove_class("selected");
                } else {
                    textLayout.get_style_context().add_class("selected");
                }
            }

            public void setPrimaryText(string? text) {
                primaryText = text;
                primaryLabel.set_text(primaryText);
            }

            public void setSecondaryText(string? text) {
                secondaryText = text;
                secondaryLabel.set_text(secondaryText);
            }

            public void setData(Object value) {
                data = value;
            }

            public Object getData() {
                return data;
            }

            public ListItem() {
                Object();

                textLayout.get_style_context().add_class("list-item");
                textLayout.get_style_context().add_class("pt-2");
                textLayout.get_style_context().add_class("pb-2");
                textLayout.get_style_context().add_class("ps-3");
                textLayout.get_style_context().add_class("pe-3");
                add(textLayout);

                primaryLabel.halign = Gtk.Align.START;
                primaryLabel.valign = Gtk.Align.END;
                primaryLabel.set_use_markup(false);
                textLayout.pack_start(primaryLabel, false);

                secondaryLabel.halign = Gtk.Align.START;
                secondaryLabel.valign = Gtk.Align.START;
                secondaryLabel.yalign = -5.0f;
                secondaryLabel.get_style_context().add_class("text-size-small");
                secondaryLabel.get_style_context().add_class("text-secondary");
                secondaryLabel.get_style_context().add_class("font-italic");
                secondaryLabel.set_use_markup(false);
                textLayout.pack_start(secondaryLabel, false);

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