using Xml;

public class FeedWidget: Gtk.Box {
    private GreetingWidget greetingWidget;

    public FeedWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(5);
        get_style_context().add_class("feed-widget");

        greetingWidget = new GreetingWidget();
        pack_start (greetingWidget.getLabel(), false);

        var layout = new Gtk.Grid();
        layout.set_hexpand(true);
        layout.set_column_homogeneous(true);
        layout.set_column_spacing(10);
        layout.set_row_spacing(10);
        pack_start(layout, true, true);

        var weatherWidget = new WeatherWidget();
        layout.attach(weatherWidget, 0, 0);

        var dummy1 = new Card();
        layout.attach(dummy1, 1, 0);

        var dummy2 = new Card();
        layout.attach(dummy2, 2, 0);

        this.map.connect(() => {
            int size = (get_allocated_width() / 3) - 20;
            layout.get_children ().foreach((child) => {
                child.set_size_request(size, size);
            });
        });

        var feedRepository = FeedRepository.getInstance();
        feedRepository.feedUpdated.connect((feedContent) => {
            update_feed(feedContent);
        });
    }

    public void update_feed(string feedContent) {
        
    }
}