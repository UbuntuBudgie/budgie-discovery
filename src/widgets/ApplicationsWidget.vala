using Gee;

public class ApplicationsWidget: Gtk.Box {
    private Gtk.FlowBox appsLayout;
    private ArrayList<ApplicationItem> allApps;
    private SortDirection sortDirection = SortDirection.ASCENDING;
    private Gtk.Button sortButton;
    private Gtk.Label pinnedLabel;
    private Gtk.Button allAppsButton = new Gtk.Button();
    private Gtk.Stack stackSwitcher = new Gtk.Stack();
    private ApplicationViewMode viewMode = ApplicationViewMode.PINNED_APPS_MODE;

    public ApplicationsWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(10);

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

        var buttonBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        pack_start(buttonBox, false);

        pinnedLabel = new Gtk.Label(_("Pinned"));
        pinnedLabel.get_style_context().add_class("text-size-normal");
        pinnedLabel.get_style_context().add_class("fw-300");
        buttonBox.pack_start(pinnedLabel, false);

        allAppsButton.margin_end = 10;
        allAppsButton.label = _("All Apps");
        buttonBox.pack_end(allAppsButton, false);

        allAppsButton.button_press_event.connect(() => {
            if(viewMode == ApplicationViewMode.PINNED_APPS_MODE) {
                viewMode = ApplicationViewMode.ALL_APPS_MODE;
                pinnedLabel.set_text(_("All Applications"));
                allAppsButton.set_label(_("Back"));
            } else {
                viewMode = ApplicationViewMode.PINNED_APPS_MODE;
                pinnedLabel.set_text(_("Pinned"));
                allAppsButton.set_label(_("All Apps"));
            }
            updateAppsLayout();
            return true;
        });

        stackSwitcher.set_vexpand(true);
        stackSwitcher.set_hexpand(true);
        var scrollView = new Gtk.ScrolledWindow(null, null);
        scrollView.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrollView.set_hexpand(true);
        scrollView.set_vexpand(true);
        scrollView.add(stackSwitcher);
        pack_start(scrollView, true, true, 0);

        appsLayout = new Gtk.FlowBox ();
        appsLayout.max_children_per_line = 7;
        stackSwitcher.add(appsLayout);

        scrollView.map.connect(() => {
            scrollView.hadjustment.value = 0;
            scrollView.vadjustment.value = 0;
        });

        map.connect(() => {
            viewMode = ApplicationViewMode.PINNED_APPS_MODE;
            pinnedLabel.set_text(_("Pinned"));
            allAppsButton.set_label(_("All Apps"));

            updateAppsLayout();
        });

        this.size_allocate.connect((allocation) => {
            int per = allocation.width / 6;
            foreach (var w in appsLayout.get_children()) {
                w.set_size_request(per, -1);

                var item = w as ApplicationItemWidget;
                if (item != null) {
                    item.set_size_request(per, -1);
                    item.label.set_size_request(per - 10, -1);
                }
            }
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
        foreach(var widget in appsLayout.get_children()) {
            appsLayout.remove(widget);
        }

        if(viewMode == ApplicationViewMode.ALL_APPS_MODE) {
            foreach(var item in this.allApps) {
                var iconWidget = new ApplicationItemWidget();
                iconWidget.setLabel(item.label);
                iconWidget.setIcon(item.icon);
                appsLayout.add(iconWidget);
            }
        }
        appsLayout.show_all();
    }
}