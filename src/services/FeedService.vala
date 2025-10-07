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
            message("stop service");
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
                                    DateTime? result = parseDate (itemChild->get_content ());
                                    feedItem.pubDate = result.format("%Y-%m-%d %H:%M");
                                }
                                
                                if(itemChild->name == "link") {
                                    feedItem.link = itemChild->get_content ();
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
                                    feedItem.pubDate = itemChild->get_content ();
                                }
                                
                                if(itemChild->name == "link") {
                                    feedItem.link = itemChild->get_prop("href");
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
            warning ("Error: %s", e.message);
        }
        fetching = false;
    }

    private DateTime parseDate(string date) {
        var parts = date.split(" ");
        var day = 0;
        var month = 0;
        var year = 0;
        var hour = 0;
        var minute = 0;
        var second = 0;

        for(var i = 0; i < parts.length; i++) {
            if(i == 0) continue;

            if(i == 1) {
                day = int.parse(parts[i]);
            }

            if(i == 2) {
                switch(parts[i]) {
                    case "Jan":
                        month = 1;
                        break;
                    case "Feb":
                        month = 2;
                        break;
                    case "Mar":
                        month = 3;
                        break;
                    case "Apr":
                        month = 4;
                        break;
                    case "Mai":
                        month = 5;
                        break;
                    case "Jun":
                        month = 6;
                        break;
                    case "Jul":
                        month = 7;
                        break;
                    case "Aug":
                        month = 8;
                        break;
                    case "Sep":
                        month = 9;
                        break;
                    case "Oct":
                        month = 10;
                        break;
                    case "Nov":
                        month = 11;
                        break;
                    case "Dec":
                        month = 12;
                        break;
                }
            }

            if(i == 3) {
                year = int.parse(parts[i]);
            }

            if(i == 4) {
                var timeParts = parts[i].split(":");
                hour = int.parse(timeParts[0]);
                minute = int.parse(timeParts[1]);
                second = int.parse(timeParts[2]);
            }
        }
        
        var formattedDate = "%4d-%02d-%02d %02d:%02d:%02d".printf(year,month,day, hour, minute, second);
        return new DateTime.from_iso8601(formattedDate, new TimeZone.local());
    }
}