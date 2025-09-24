public class BookmarkItemWidget: BasicIconTextWidget {
    private BookmarkItem item;
    public BookmarkItemWidget(Budgie.Popover popover, BookmarkItem item) {
        base();
        this.item = item;
        this.setLabel(item.name);
        this.setIcon(item.uri);
    }

    public new void setIcon(string value) {
        if(value == null) {
            message("Unable to set icon for bookmark %s", item.uri);
            return;
        }

        Icon gicon;
        try {
            var f = File.new_for_uri(item.uri);
            if (f.has_uri_scheme("file")) {
                var info = f.query_info("standard::icon", 0, null);
                gicon = info.get_icon();
            } else {
                gicon = new ThemedIcon("folder");
            }
        } catch (Error e) {
            gicon = new ThemedIcon("folder");
        }
        icon.set_from_gicon(gicon, Gtk.IconSize.BUTTON);
    }
}