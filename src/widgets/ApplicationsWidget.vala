using Gee;

public class ApplicationsWidget: Gtk.Box {
    private Gtk.Grid appsLayout;
    private ArrayList<ApplicationItem> allApps;
    private SortDirection sortDirection = SortDirection.ASCENDING;
    private Gtk.Button sortButton;
    private Budgie.Popover popover;

    public ApplicationsWidget(Budgie.Popover parent) {
        Object();
        popover = parent;
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(10);
        get_style_context().add_class("applications-widget");

        var headerWidget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        headerWidget.get_style_context().add_class ("header-widget");
        pack_start(headerWidget, false, true);

        var headerLabel = new Gtk.Label(_("Applications"));
        headerLabel.set_halign(Gtk.Align.START);
        headerLabel.get_style_context().add_class ("header-label");
        headerWidget.pack_start(headerLabel, true);

        var addButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        headerWidget.pack_end(addButton, false); 

        sortButton = new Gtk.Button.from_icon_name("go-down-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        headerWidget.pack_end(sortButton, false);


        var scrollView = new Gtk.ScrolledWindow(null, null);
        scrollView.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrollView.set_hexpand(true);
        scrollView.set_vexpand(true);
        scrollView.set_overlay_scrolling(false);

        appsLayout = new Gtk.Grid ();
        appsLayout.get_style_context().add_class("card");
        appsLayout.get_style_context().add_class("p-3");
        appsLayout.set_row_spacing(10);
        appsLayout.set_column_spacing(10);
        appsLayout.set_halign(Gtk.Align.FILL);
        appsLayout.set_valign(Gtk.Align.START);
        scrollView.add(appsLayout);
        pack_start(scrollView, true, true, 0);

        scrollView.map.connect(() => {
            scrollView.hadjustment.value = 0;
            scrollView.vadjustment.value = 0;
        });

        sortButton.button_press_event.connect(() => {
            sortDirection = sortDirection == SortDirection.ASCENDING ? SortDirection.DESCENDING : 
                SortDirection.ASCENDING;

            if(sortDirection == SortDirection.ASCENDING) {
                var icon = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                this.sortButton.image = icon;
                this.allApps.sort((left, right) => {
                    return left.label.ascii_casecmp(right.label);
                });
            } else {
                var icon = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                this.sortButton.image = icon;
                this.allApps.sort((left, right) => {
                    return right.label.ascii_casecmp(left.label);
                });
            }
            updateAppsLayout();
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
        this.allApps = list;
        this.allApps.sort((left, right) => {
            return sortDirection == SortDirection.ASCENDING ? left.label.ascii_casecmp(right.label) :
                right.label.ascii_casecmp(right.label);
        });

        updateAppsLayout();
    }

    private void updateAppsLayout() {
        appsLayout.foreach((child) => appsLayout.remove(child));

        int col = 0;
        int row = 0;
        int maxCols = 6;

        var items = (Gee.Iterable<ApplicationItem>)allApps;
        foreach (var item in items) {
            var iconWidget = new ApplicationItemWidget(popover, item);
            iconWidget.set_size_request(100, 100);
            appsLayout.attach(iconWidget, col, row, 1, 1);

            col++;
            if (col >= maxCols) {
                col = 0;
                row++;
            }
        }
        appsLayout.show_all();
    }
}