using Gee;

public class FeedView: Gtk.ScrolledWindow {
    private Gtk.Layout feedLayout = new Gtk.Layout();
    private static Budgie.Popover popover;
    private FeedService feedService;

    public FeedView(Budgie.Popover bp, FeedConfigItem c) {
        Object();
        popover = bp;
        hexpand = true;
        vexpand = true;
        margin_top = 10;
        get_style_context().add_class("news-feed-layout");
        get_style_context().add_class("feed-list");
        overlay_scrolling = false;
        set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

        feedLayout.hexpand = true;
        add(feedLayout);

        map.connect(() => {
            hadjustment.value = 0;
            vadjustment.value = 0;
        });

        feedLayout.size_allocate.connect((allocation) => {
            resizeChildren();
        });

        feedService = new FeedService(c);
        feedService.feedFetched.connect(onFeedFetched);
        Idle.add(() => {
            feedService.start_service ();
            return false;
        });
    }

    ~FeedView() {
        feedService.stop_service();
    }

    public void reload() {
        feedService.update_service(true);
    }

    private void resizeChildren() {
        int width = get_allocated_width();
        if(width <= 1) return;

        int widgetSize = (width / 2) - 15;
        int column = 0;
        int row = 0;
        int y = 0;
        feedLayout.get_children().foreach(child => {
            int x = column == 0 ? 0 : widgetSize + 10;

            child.set_size_request(widgetSize, widgetSize);
            feedLayout.move(child, x, y);

            if(column == 0) {
                column++;
            } else {
                column = 0;
                row++;
                y += widgetSize + 10;
            }
        });

        int total_height = (row * widgetSize) + ((row - 1) * 10);
        feedLayout.set_size(width - 20, total_height);
    }

    private void onFeedFetched(ArrayList<FeedItem>? items) {
        feedLayout.foreach ((element) => {
            feedLayout.remove(element);
            element.destroy();
            element = null;
        });

        foreach(var feedItem in items) {
            var card = new FeedItemWidget(feedItem);
            feedLayout.add(card);
            card.clicked.connect(() => {
                popover.hide();
            });
        }

        show_all();
    }
}