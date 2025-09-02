using Config;
using GLib;
using Posix;
using Soup;
using Gee;

public class FeedRepository {
    private static FeedRepository instance = null;
    private static string filePath = null;

    public signal void feedUpdated(ArrayList<FeedItem>? feedList);

    public static FeedRepository getInstance() {
        if(instance == null) {
            instance = new FeedRepository();
        }

        if (filePath == null) {
            string localSharePackageDir = Environment.get_home_dir() + "/.local/share/budgie-desktop/plugins/" + PACKAGE_NAME;
            if( !FileUtils.test(localSharePackageDir, FileTest.IS_DIR)) {
                mkdir(localSharePackageDir, 0755);
            }
            filePath = localSharePackageDir + "/feed.xml";
        }

        return instance;
    }

    public void save(string data) {
        if (filePath == null) {
            warning("File path is not set. Cannot save data.\n");
            return;
        }
        
        try {
            FileUtils.set_contents(filePath, data);
            load(); // Load the data after saving
        } catch (Error e) {
            warning("Failed to save weather data: %s\n", e.message);
        }
        
    }

    public void load() {
        if (filePath == null) {
            warning("File path is not set. Cannot load data.\n");
            return;
        }
        
        try {
            if(FileUtils.test(filePath, FileTest.IS_REGULAR)) {
                var feedList = new ArrayList<FeedItem>();
                Xml.Doc* doc = Xml.Parser.parse_file (filePath);
                Xml.Node *root = doc->get_root_element ();
                Xml.Node* channel = root->first_element_child();
                if (channel->name == "channel") {
                    for (Xml.Node* item = channel->children; item != null; item = item->next) {
                        if (item->name == "item") {
                            FeedItem feedItem = new FeedItem();
                            for (Xml.Node *itemChild = item->children; itemChild != null; itemChild = itemChild->next) {
                                if (itemChild->name == "title") {
                                    var titleData = itemChild->get_content ();
                                    var title = titleData.substring(0, titleData.last_index_of(" - "))
                                        .chomp().chug();

                                    var publisher = titleData.substring(titleData.last_index_of(" - ")+3);
                                    feedItem.title = title;
                                    feedItem.publisher = publisher;
                                }

                                if(itemChild->name == "pubDate") {
                                    DateTime? result = parseDate (itemChild->get_content ());
                                    feedItem.pubDate = result.format("%Y-%m-%d %H:%M");
                                }
                            }

                            message("%s - %s", feedItem.title, feedItem.pubDate);
                            feedList.add (feedItem);
                        } else {
                            message("item name = " + item->name); // Debug output
                        }
                    }
                }
                feedUpdated(feedList);
            }
        } catch (Error e) {
            warning("Failed to load weather data: %s\n", e.message);
        }
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