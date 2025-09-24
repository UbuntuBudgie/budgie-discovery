public class BookmarksWidget: Gtk.Box {
    public BookmarksWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(5);

        var headerWidget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        headerWidget.get_style_context().add_class ("header-widget");
        pack_start(headerWidget, false, true);

        var headerLabel = new Gtk.Label(_("Bookmarks"));
        headerLabel.set_halign(Gtk.Align.START);
        headerLabel.get_style_context().add_class ("header-label");
        headerWidget.pack_start(headerLabel, true);

        var infoLabel = new Gtk.Label(_("No bookmarks available."));
        infoLabel.set_halign(Gtk.Align.CENTER);
        infoLabel.set_valign(Gtk.Align.CENTER);
        infoLabel.get_style_context().add_class("dim-label");
        pack_start(infoLabel, true, true, 0);
    }
}