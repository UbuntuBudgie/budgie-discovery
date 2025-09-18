using Gee;
using GLib;

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
                if(name.has_suffix (".desktop")) {
                    var path = Path.build_filename (shareDirName, name);
                    if(FileUtils.test (path, GLib.FileTest.IS_REGULAR)) {
                        files.add (path);
                    }
                }
            }

            var locale = GLib.Intl.get_language_names ()[0];
            if(locale != null && locale != "C") {
                locale = locale.split(".")[0].split("_")[0];
            } else {
                locale = "en";
            }

            message("FOUND LOCALE = %s", locale);

            foreach(var fileName in files) {
                bool isDesktopEntry = false;
                bool isTerminal = false;
                bool ignore = false;
                string action = null;
                string icon = null;
                string applicationName = null;
                string localeName = null;
                string genericName = null;

                File file = File.new_for_path (fileName);
                try {
                    FileInputStream @is = file.read ();
                    if(is == null) {
                        error("Unable to read from file %s", fileName);
                    }

                    DataInputStream dis = new DataInputStream (@is);

                    string lineContent;
                    while ((lineContent = dis.read_line ()) != null) {
                        if(lineContent.index_of("#") == 0) continue;
                        if(lineContent == "[Desktop Entry]") {
                            isDesktopEntry = true;
                            continue;
                        }

                        if(lineContent.index_of("[Desktop ") == 0 && isDesktopEntry) {
                            break;
                        }
                        
                        if(!isDesktopEntry) continue;

                        string[] lineParts = lineContent.split("=");
                        if(lineParts.length != 2) continue;

                        if(lineParts[0] == "Terminal") {
                            isTerminal = bool.parse(lineParts[1]);
                        }
                        if(lineParts[0] == "NoDisplay") {
                            ignore = bool.parse(lineParts[1]);
                        }
                        if(lineParts[0] == "Icon") {
                            icon = lineParts[1];
                        }
                        if(lineParts[0] == "Name" && applicationName == null) {
                            applicationName = lineParts[1];
                        }
                        if(lineParts[0] == "Name[%s]".printf(locale)) {
                            localeName = lineParts[1];
                        }
                        if(lineParts[0] == "GenericName[%s]".printf(locale)) {
                            genericName = lineParts[1];
                        }
                        if(lineParts[0] == "Exec") {
                            action = lineParts[1];
                        }
                    }

                    if(!isDesktopEntry || isTerminal || ignore) continue;
                    var app = new ApplicationItem();
                    app.icon = icon;
                    app.label = applicationName;
                    app.action = action;
                    app.desktopFilePath = fileName;

                    if(genericName != null) {
                        app.label = genericName;
                    }
                    if(applicationName != null) {
                        app.label = applicationName;
                    }
                    if(localeName != null) {
                        app.label = localeName;
                    }
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