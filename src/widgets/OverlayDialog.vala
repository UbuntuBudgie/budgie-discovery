public class OverlayDialog: Gtk.Box {
    private Gtk.Label dialogTitleLabel = new Gtk.Label(null);
    private Gtk.Box dialogLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
    private Gtk.Box buttonBar = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
    private Gtk.Box contentArea = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    protected Gtk.Button okButton;
    protected Gtk.Button cancelButton;

    public signal void ok_button_pressed(OverlayDialog dialog);
    public signal void cancel_button_pressed(OverlayDialog dialog);

    public OverlayDialog() {
        Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
        hexpand = true;
        vexpand = true;
        valign = Gtk.Align.START;
        halign = Gtk.Align.FILL;
        get_style_context().add_class("dialog-overlay");

        var frame = new Gtk.Frame(null);
        frame.get_style_context().add_class("background");
        frame.set_shadow_type(Gtk.ShadowType.ETCHED_IN);
        frame.margin_start = 100;
        frame.margin_end = 100;
        frame.margin_top = 50;
        frame.hexpand = true;
        frame.vexpand = true;
        frame.set_size_request(-1, 300);

        contentArea.halign = Gtk.Align.FILL;
        contentArea.valign = Gtk.Align.FILL;
        contentArea.hexpand = true;
        contentArea.vexpand = true;
        contentArea.margin_start = contentArea.margin_end = 
            contentArea.margin_top = contentArea.margin_bottom = 10;

        okButton = new Gtk.Button.with_label (_("OK"));
        okButton.halign = Gtk.Align.END;
        
        cancelButton = new Gtk.Button.with_label (_("Cancel"));
        cancelButton.halign = Gtk.Align.END;

        buttonBar.margin_end = 10;
        buttonBar.margin_bottom = 10;
        buttonBar.pack_end (okButton, false);
        buttonBar.pack_end (cancelButton, false);

        dialogTitleLabel.halign = Gtk.Align.START;
        dialogTitleLabel.margin_start = 10;
        dialogLayout.pack_start (dialogTitleLabel, false);
        dialogLayout.pack_start(contentArea, true);
        dialogLayout.pack_end(buttonBar, false);

        frame.add(dialogLayout);
        pack_start(frame, true, false, 0);

        okButton.clicked.connect(() => {
            ok_button_pressed(this);
        });

        cancelButton.clicked.connect(() => {
            cancel_button_pressed(this);
        });
    }

    public void setTitle(string title) {
        dialogTitleLabel.set_text(title);
    }

    public Gtk.Box getContentArea() {
        return contentArea;
    }
}