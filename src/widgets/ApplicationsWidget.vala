using Gee;

public class ApplicationsWidget: Gtk.Box {
    private Gtk.FlowBox layout;
    private ArrayList<ApplicationItem> items;
    private SortDirection sortDirection = SortDirection.ASCENDING;
    private Gtk.Button sortButton;

    public ApplicationsWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(10);

        var headerWidget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        headerWidget.get_style_context().add_class ("header-widget");
        pack_start(headerWidget, false, true);

        var headerLabel = new Gtk.Label(_("Applications"));
        headerLabel.set_halign(Gtk.Align.START);
        headerLabel.get_style_context().add_class ("header-label");
        headerWidget.pack_start(headerLabel, true);

        sortButton = new Gtk.Button.from_icon_name("go-down-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        headerWidget.pack_end(sortButton, false);

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

        sortButton.button_press_event.connect(() => {
            sortDirection = sortDirection == SortDirection.ASCENDING ? SortDirection.DESCENDING : 
                SortDirection.ASCENDING;

            if(sortDirection == SortDirection.ASCENDING) {
                var icon = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                this.sortButton.image = icon;
                this.items.sort((left, right) => {
                    return left.label.ascii_casecmp(right.label);
                });
            } else {
                var icon = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                this.sortButton.image = icon;
                this.items.sort((left, right) => {
                    return right.label.ascii_casecmp(left.label);
                });
            }

            foreach(var widget in layout.get_children()) {
                layout.remove(widget);
            }

            foreach(var item in this.items) {
                var iconWidget = new ApplicationItemWidget();
                iconWidget.setLabel(item.label);
                iconWidget.setIcon(item.icon);
                layout.add(iconWidget);
            }

            layout.show_all();

            return true;
        });

        var service = new ApplicationService ();

        service.change.connect(onAppsChange);
        
        Idle.add(() => {
            service.start_service();
            return false;
        });
    }

    private void onAppsChange(ArrayList<ApplicationItem> list) {
        foreach(var widget in layout.get_children()) {
            layout.remove(widget);
        }

        this.items = list;
        this.items.sort((left, right) => {
            return sortDirection == SortDirection.ASCENDING ? left.label.ascii_casecmp(right.label) :
                right.label.ascii_casecmp(right.label);
        });

        foreach(var item in this.items) {
            var iconWidget = new ApplicationItemWidget();
            iconWidget.setLabel(item.label);
            iconWidget.setIcon(item.icon);
            layout.add(iconWidget);
        }

        layout.show_all();
    }
}