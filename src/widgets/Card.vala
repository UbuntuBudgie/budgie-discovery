public class Card: Gtk.Box {
    
    public Card() {
        Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
        get_style_context().add_class("card");
        get_style_context().add_class("frame");
        get_style_context().add_class("shadowed");

        try {
            var css_provider = new Gtk.CssProvider();
            css_provider.load_from_data("""
            .shadowed {
                background-color: @theme_base_color;
                box-shadow: 0 0 3px rgba(0,0,0,0.125);
            }
            """);
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        } catch(Error e) {
            // not handled
        }

    }
}