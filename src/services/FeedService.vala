using Gee;
using GLib;

public class FeedService: Service {
    private bool fetching = false;
    private DateTime lastFetched;
    private FeedConfigItem config;
    private uint timer = 0;
    private static string cacheDir;

    public signal void feedFetched(ArrayList<FeedItem> items);

    public FeedService(FeedConfigItem configItem) {
        config = configItem;
        if(cacheDir == null) {
            cacheDir = "%s/discovery-applet".printf(Environment.get_user_cache_dir());
            DirUtils.create_with_parents(cacheDir, 0700);
        }
    }

    ~FeedService() {
        stop_service();
    }

    public new void start_service() {
        if(timer != 0) return;
        update_service(false);
        timer = Timeout.add_seconds(5, () => {
            update_service(false);
            return true;
        });
    }

    public new void stop_service() {
        if(timer != 0) {
            Source.remove(timer);
            timer = 0;
        }
    }

    public new void update_service(bool force) {
        if(fetching) return;
        DateTime current = new DateTime.now_local();
        if(lastFetched != null) {
            if(lastFetched.add_hours(1).to_unix() > current.to_unix() && !force) {
                return;
            }
        }
        fetchData(force);
    }

    private void fetchData(bool force) {
        fetching = true;
        try {
            var file = File.new_for_uri(config.uri);
            string etag_out;
            uint8[]? contents;
            file.load_contents (null, out contents, out etag_out);
            
            var cacheFilePath = "%s/%s.xml".printf(cacheDir, config.uid);
            FileUtils.set_contents(cacheFilePath, (string)contents, ((string)contents).length);

            if(FileUtils.test(cacheFilePath, FileTest.IS_REGULAR)) {
                var feedList = new ArrayList<FeedItem>();
                Xml.Doc* doc = Xml.Parser.parse_file (cacheFilePath);
                Xml.Node *root = doc->get_root_element ();

                if (root->name == "rss") {
                    Xml.Node* channel = root->first_element_child();
                    for (Xml.Node* item = channel->children; item != null; item = item->next) {
                        if (item->name == "item") {
                            FeedItem feedItem = new FeedItem();
                            for (Xml.Node *itemChild = item->children; itemChild != null; itemChild = itemChild->next) {
                                if (itemChild->name == "title") {
                                    var title = itemChild->get_content ();
                                    feedItem.title = title;
                                }

                                if(itemChild->name == "pubDate") {
                                    if(feedItem.pubDate == null) {
                                        feedItem.pubDate = itemChild->get_content ();
                                    }
                                }
                                
                                if(itemChild->name == "link") {
                                    feedItem.link = itemChild->get_content ();
                                }

                                if(itemChild->name == "updated") {
                                    feedItem.pubDate = itemChild->get_content ();
                                }
                            }

                            feedList.add (feedItem);
                        }
                    }
                } else if(root->name == "feed") {
                    for (Xml.Node* item = root->children; item != null; item = item->next) {
                        if(item->name == "entry") {
                            FeedItem feedItem = new FeedItem();
                            for (Xml.Node *itemChild = item->children; itemChild != null; itemChild = itemChild->next) {
                                if (itemChild->name == "title") {
                                    var title = itemChild->get_content ();
                                    feedItem.title = title;
                                }

                                if(itemChild->name == "published") {
                                    if(feedItem.pubDate == null) {
                                        feedItem.pubDate = itemChild->get_content ();
                                    }
                                }
                                
                                if(itemChild->name == "link") {
                                    feedItem.link = itemChild->get_prop("href");
                                }

                                if(itemChild->name == "id") {
                                    //feedItem.link = itemChild->get_content();
                                }

                                if(itemChild->name == "updated") {
                                    feedItem.pubDate = itemChild->get_content ();
                                }
                            }

                            feedList.add (feedItem);
                        }
                    }
                }
                feedFetched(feedList);
            }

            lastFetched = new DateTime.now_local();
        } catch (Error e) {
            warning(e.message);
            stop_service();
        }
        fetching = false;
    }
}