using Config;
using GLib;
using Posix;
using Gee;
//using Xml;

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
                            }
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
}