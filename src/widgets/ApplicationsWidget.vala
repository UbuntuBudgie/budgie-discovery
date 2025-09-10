using Gee;

public class ApplicationsWidget: Gtk.Box {
    private Gtk.FlowBox layout;

    public ApplicationsWidget() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("applications-widget");

        var scrollView = new Gtk.ScrolledWindow(null, null);
        pack_start(scrollView, true);

        layout = new Gtk.FlowBox ();
        layout.max_children_per_line = 4;
        scrollView.add(layout);

        layout.map.connect(() => {
            var itemWidth = get_allocated_width() / 4;
            message("layout map event");
            foreach(var widget in layout.get_children()) {
                widget.set_size_request (itemWidth, -1);
            }
        });

        var service = new ApplicationService ();

        service.change.connect(onAppsChange);
        
        Idle.add(() => {
            service.start_service();
            return false;
        });
    }

    private void onAppsChange(ArrayList<ApplicationItem> items) {
        foreach(var widget in layout.get_children()) {
            layout.remove(widget);
        }

        foreach(var item in items) {
            var iconWidget = new ApplicationItemWidget();
            iconWidget.setLabel(item.label);
            layout.add(iconWidget);
        }

        layout.show_all();
    }
}