using Gee;

public class FeedView: Gtk.ScrolledWindow {
    private Gtk.Grid feedLayout;
    private static Budgie.Popover popover;
    private FeedService feedService;

    public FeedView(Budgie.Popover bp, FeedConfigItem c) {
        Object();
        popover = bp;
        margin_top = 10;

        set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        overlay_scrolling = false;
        shadow_type = Gtk.ShadowType.NONE;

        feedLayout = new Gtk.Grid();
        feedLayout.get_style_context().add_class("news-feed-layout");
        feedLayout.set_column_spacing(10);
        feedLayout.set_row_spacing(10);
        add(feedLayout);

        map.connect(() => {
            hadjustment.value = 0;
            vadjustment.value = 0;
        });

        feedLayout.map.connect(() => {
        });

        feedService = new FeedService(c);
        feedService.feedFetched.connect(onFeedFetched);
        Idle.add(() => {
            feedService.start_service ();
            return false;
        });

        show_all();
    }

    ~FeedView() {
        feedService.stop_service();
    }

    public void reload() {
        feedService.update_service(true);
    }

    private void onFeedFetched(ArrayList<FeedItem>? items) {
        feedLayout.foreach ((element) => {
            element.destroy();
        });

        var currentColumn = 0;
        var currentRow = 0;
        foreach(var feedItem in items) {
            var card = new FeedItemWidget(feedItem);
            feedLayout.attach(card, currentColumn, currentRow);

            card.clicked.connect(() => {
                popover.hide();
            });

            if(currentColumn == 1) {
                currentColumn = 0;
                currentRow++;
            } else {
                currentColumn++;
            }
        }

        show_all();
    }
}