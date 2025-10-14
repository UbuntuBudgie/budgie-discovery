public class ListItem: Gtk.EventBox {
    private Gtk.Box mainLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
    private Gtk.Box textLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box actionLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
    private Object data;
    private Gtk.Label primaryLabel = new Gtk.Label(null);
    private Gtk.Label secondaryLabel = new Gtk.Label(null);

    private bool selectable = true;
    private string? primaryText;
    private string? secondaryText;

    public signal void selected();

    public void setSelected(bool value) {
        if(!selectable) return;
        if(!value) {
            mainLayout.get_style_context().remove_class("selected");
        } else {
            mainLayout.get_style_context().add_class("selected");
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

    public void setSelectable(bool value) {
        selectable = value;
    }

    public void addActionButton(Gtk.Button btn) {
        actionLayout.pack_start(btn, false);
    }

    public ListItem() {
        Object();

        this.realize.connect(() => {
            mainLayout.get_style_context().add_class("list-item");
            mainLayout.get_style_context().add_class("pt-2");
            mainLayout.get_style_context().add_class("pb-2");
            mainLayout.get_style_context().add_class("ps-3");
            mainLayout.get_style_context().add_class("pe-3");
        });

        add(mainLayout);

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

        mainLayout.pack_start(textLayout, true, true);
        mainLayout.pack_end(actionLayout, false);

        add_events(Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK | Gdk.EventMask.BUTTON_PRESS_MASK);
        this.enter_notify_event.connect(() => {
            if(!mainLayout.get_style_context().has_class("selected"))
                mainLayout.get_style_context().add_class("hover");
            return true;
        });
        this.leave_notify_event.connect(() => {
            mainLayout.get_style_context().remove_class("hover");
            return true;
        });
        this.button_press_event.connect(() => {
            if(!selectable) return true;
            this.setSelected(true);
            mainLayout.get_style_context().remove_class("hover");
            selected();
            return true;
        });
    }
}