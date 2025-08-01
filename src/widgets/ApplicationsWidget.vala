public class ApplicationsWidget: Gtk.Box {
    private Gtk.Label applicationsLabel;

    public ApplicationsWidget() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("applications-widget");

        applicationsLabel = new Gtk.Label("FeApplications content will be displayed here.");
        applicationsLabel.set_halign(Gtk.Align.CENTER);
        applicationsLabel.set_valign(Gtk.Align.CENTER);
        pack_start(applicationsLabel, true, true, 0);
    }
}