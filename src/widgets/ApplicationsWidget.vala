using Gee;

public class ApplicationsWidget: Gtk.Box {

    public ApplicationsWidget() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("applications-widget");

        var layout = new Gtk.FlowBox ();
        var service = new ApplicationService ();
        
        Idle.add(() => {
            service.start_service();
            return false;
        });
    }
}