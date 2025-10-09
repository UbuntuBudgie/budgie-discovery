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
        fetchData.begin(force);
    }

    private async void fetchData(bool force) {
        fetching = true;
        try {
            var session = SessionManager.get_default();
            var msg = new Soup.Message ("GET", config.uri);
            msg.request_headers.append ("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
            msg.request_headers.append ("Accept-Language", "de-DE,de;q=0.9,en;q=0.8");
            msg.request_headers.append("User-Agent", session.user_agent);
            msg.request_headers.append ("Sec-Fetch-Dest", "image");
            msg.request_headers.append ("Sec-Fetch-Mode", "no-cors");
            msg.request_headers.append ("Sec-Fetch-Site", "cross-site");
            msg.request_headers.append ("Upgrade-Insecure-Requests", "1");
            msg.request_headers.append ("Connection", "keep-alive");

            var bytes = yield session.send_and_read_async(msg, Priority.DEFAULT, null);
            if (msg.get_status () != 200) {
                return;
            }

            var contents = (string) bytes.get_data ();
            contents = contents.substring (0, (int) bytes.get_size ());
            
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

                            // TODO download feed source and cache images here
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

                                if(itemChild->name == "updated") {
                                    feedItem.pubDate = itemChild->get_content ();
                                }
                            }

                            // TODO download feed source and cache images here

                            feedList.add (feedItem);
                        }
                    }
                }
                feedFetched(feedList);
            }

            lastFetched = new DateTime.now_local();
        } catch (Error e) {
            warning(e.message);
        }
        fetching = false;
    }
}