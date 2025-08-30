public class Card: Gtk.Box {
    
    public Card() {
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(0);
        get_style_context().add_class("card");
    }
}