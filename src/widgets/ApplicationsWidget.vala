using Gee;

public class ApplicationsWidget: Gtk.Box {
    private Gtk.FlowBox layout;

    public ApplicationsWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(10);

        var headerLabel = new Gtk.Label(_("Applications"));
        headerLabel.set_halign(Gtk.Align.START);
        headerLabel.get_style_context().add_class ("header-label");
        headerLabel.get_style_context().add_class ("header-widget");
        pack_start(headerLabel, false, true);

        var scrollView = new Gtk.ScrolledWindow(null, null);
        scrollView.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrollView.set_hexpand(true);
        scrollView.set_vexpand(true);
        pack_start(scrollView, true, true, 0);

        layout = new Gtk.FlowBox ();
        layout.max_children_per_line = 7;
        scrollView.add(layout);

        this.size_allocate.connect((allocation) => {
            int per = allocation.width / 6;
            foreach (var w in layout.get_children()) {
                w.set_size_request(per, -1);

                var item = w as ApplicationItemWidget;
                if (item != null) {
                    item.set_size_request(per, -1);
                    item.label.set_size_request(per - 10, -1); // Label direkt beschränken
                }
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

        items.sort((left, right) => {
            return left.label.ascii_casecmp(right.label);
        });

        foreach(var item in items) {
            var iconWidget = new ApplicationItemWidget();
            iconWidget.setLabel(item.label);
            iconWidget.setIcon(item.icon);
            layout.add(iconWidget);
        }

        layout.show_all();
    }
}