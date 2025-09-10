using Gee;

public class ApplicationService: IService {
    public signal void change(ArrayList<ApplicationItem> apps);
    public void start_service () {
        update_service (false);
    }

    public void stop_service () {
        assert_not_reached ();
    }

    public void update_service (bool force) {
        ArrayList<ApplicationItem> apps = new ArrayList<ApplicationItem>();
        ArrayList<string> files = new ArrayList<string>();

        try {
            var localDirName = Environment.get_user_data_dir () + "/applications";
            var dir = Dir.open (localDirName, 0);
            string name = null;
            while((name = dir.read_name ()) != null) {
                if(name.index_of (".desktop", 0) > 0) {
                    var path = Path.build_filename (localDirName, name);
                    if(FileUtils.test (path, GLib.FileTest.IS_REGULAR)) {
                        files.add (path);
                    }
                }
            }

            var shareDirName = "/usr/share/applications";
            dir = Dir.open (shareDirName, 0);
            name = null;
            while((name = dir.read_name ()) != null) {
                if(name.index_of (".desktop", 0) > 0) {
                    var path = Path.build_filename (shareDirName, name);
                    if(FileUtils.test (path, GLib.FileTest.IS_REGULAR)) {
                        files.add (path);
                    }
                }
            }

            foreach(var fileName in files) {
                bool isDesktopEntry = false;
                bool isTerminal = false;
                bool ignore = false;
                string icon = null;
                string applicationName = null;

                File file = File.new_for_path (fileName);
                try {
                    FileInputStream @is = file.read ();
                    if(is == null) {
                        error("Unable to read from file %s", fileName);
                    }

                    DataInputStream dis = new DataInputStream (@is);

                    string lineContent;
                    int line = 0;
                    while ((lineContent = dis.read_line ()) != null) {
                        if(lineContent.index_of("#") == 0) continue;
                        if(line == 0) {
                            if(lineContent.index_of("[Desktop Entry]") >= 0 || lineContent.index_of("[desktop entry]") >= 0) {
                                isDesktopEntry = true;
                                line++;
                                continue;
                            } else {
                                break;
                            }
                        }

                        if(lineContent.index_of("[Desktop Action]") == 0) {
                            message("ignore desktop actions: %s", fileName);
                            break;
                        }
                        
                        string[] lineParts = lineContent.split("=");
                        if(lineParts[0] == "Terminal") {
                            isTerminal = bool.parse(lineParts[1]);
                        }
                        if(lineParts[0] == "NoDisplay") {
                            ignore = bool.parse(lineParts[1]);
                        }
                        if(lineParts[0] == "Icon") {
                            icon = lineParts[1];
                        }
                        if(lineParts[0] == "Name") {
                            applicationName = lineParts[1];
                        }
                    }

                    if(!isDesktopEntry || isTerminal || ignore) continue;
                    var app = new ApplicationItem();
                    app.icon = icon;
                    app.label = applicationName;
                    apps.add(app);

                } catch (Error e) {
                    print ("Error: %s\n", e.message);
                }
            }
            change (apps);
            
        } catch(Error e) {
            error("Error in Discovery applet: %s", e.message);
        }

    }
    
}