using Gee;
using GLib;
using Xml;

public class FeedWidget: Gtk.Box {
    private GreetingWidget greetingWidget;
    private Gtk.Grid feedLayout = new Gtk.Grid();
    private Gtk.Box widgetLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
    private int currentColumn = 0;
    private int currentRow = 0;

    private Gtk.Label currentDateLabel = new Gtk.Label("");

    public FeedWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(0);
        get_style_context().add_class("feed-widget");

        pack_start(currentDateLabel, false);
        currentDateLabel.set_halign(Gtk.Align.START);
        currentDateLabel.get_style_context().add_class("text-size-small");

        greetingWidget = new GreetingWidget();
        pack_start (greetingWidget.getLabel(), false);

        var mainLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        pack_start(mainLayout, true);

        mainLayout.pack_start(widgetLayout, true, true);

        var feedBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
        var feedsLabel = new Gtk.Label("Feed");
        feedsLabel.get_style_context().add_class("text-size-small");
        feedsLabel.set_halign(Gtk.Align.START);
        feedBox.pack_start(feedsLabel, false);

        feedLayout.set_hexpand(true);
        feedLayout.set_column_homogeneous(true);
        feedLayout.set_column_spacing(10);
        feedLayout.set_row_spacing(10);

        var feedView = new Gtk.ScrolledWindow(null, null);
        feedView.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        feedView.add(feedLayout);
        feedView.overlay_scrolling = false;
        feedView.shadow_type = Gtk.ShadowType.NONE;
        feedBox.pack_start(feedView);

        mainLayout.pack_start(feedBox, true, true);

        Timeout.add_seconds(1, () => {
            var now = new DateTime.now_local();
            currentDateLabel.set_label(now.format("%A, %d. %B"));
            return true;
        });

        var widgetsLabel = new Gtk.Label("Widgets");
        widgetsLabel.get_style_context().add_class("text-size-small");
        widgetsLabel.set_halign(Gtk.Align.START);
        widgetLayout.pack_start(widgetsLabel, false);

        var weatherWidget = new WeatherWidget();
        widgetLayout.pack_start(weatherWidget, false);

        this.map.connect(resizeChildren);

        var feedRepository = FeedRepository.getInstance();
        feedRepository.feedUpdated.connect(update_feed);
    }

    private void resizeChildren() {
        int size = (get_allocated_width() / 3) - 20;
        var index = 0;
        widgetLayout.get_children ().foreach((child) => {
            if(index == 0) {
                index++;
                return;
            }

            child.set_size_request(size, size);
            index++;
        });

        feedLayout.get_children ().foreach((child) => {
            child.set_size_request(size, size);
        });
    }

    public void update_feed(ArrayList<FeedItem>? feedList) {
        if(feedList == null) return;

        feedLayout.foreach ((element) => {
            element.destroy();
        });

        currentColumn = 0;
        currentRow = 0;

        int size = (get_allocated_width() / 3) - 20 - 10;
        foreach(var feedItem in feedList) {
            var card = new Card();

            var image = new Gtk.Image();
            card.pack_start(image, false);
            image.get_style_context().add_class("card-image");
            image.set_size_request(120, 120);

            Gtk.Label label = new Gtk.Label("");
            label.get_style_context().add_class("card-title");
            label.set_label(feedItem.title);
            label.set_line_wrap(true);
            label.set_line_wrap_mode(Pango.WrapMode.WORD);
            label.set_lines(3);
            label.set_ellipsize(Pango.EllipsizeMode.END);
            label.set_justify(Gtk.Justification.LEFT);
            label.set_halign(Gtk.Align.START);
            label.set_valign(Gtk.Align.START);
            label.hexpand = true;
            label.xalign = 0;
            card.pack_start(label,true);

            feedLayout.attach(card, currentColumn, currentRow);

            if(currentColumn == 1) {
                currentColumn = 0;
                currentRow++;
            } else {
                currentColumn++;
            }
        }

        if(size > 0) {
            resizeChildren();
        }

        show_all();
    }
}