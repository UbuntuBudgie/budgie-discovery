using Gee;
using GLib;

public class ApplicationService: Service {
    public signal void change(ArrayList<ApplicationItem> apps);

    public new void start_service () {
        update_service (false);
        AppInfoMonitor monitor = AppInfoMonitor.get();
        monitor.changed.connect(() => {
            update_service(true);
        });
    }

    public new void stop_service () {
        // do nothing
    }

    public new void update_service (bool force) {
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

            foreach(var fileName in files) {
                string action = null;
                string icon = null;
                string applicationName = null;

                KeyFile file = new KeyFile ();
                file.load_from_file (fileName, GLib.KeyFileFlags.NONE);

                if(file.has_group ("Desktop Entry")) {
                    if(file.has_key ("Desktop Entry", "Terminal")) {
                        if(file.get_boolean ("Desktop Entry", "Terminal")) {
                            continue;
                        }
                    }
                    if(file.has_key ("Desktop Entry", "NoDisplay")) {
                        if(file.get_boolean ("Desktop Entry", "NoDisplay")) {
                            continue;
                        }
                    }
                    if(file.has_key ("Desktop Entry", "Type")) {
                        if(file.get_string  ("Desktop Entry", "Type") != "Application") {
                            continue;
                        }
                    }
                    if(
                        !file.has_key ("Desktop Entry", "Name") && 
                        !file.has_key ("Desktop Entry", "Name[%s]".printf(locale)) && 
                        !file.has_key ("Desktop Entry", "GenericName") && 
                        !file.has_key ("Desktop Entry", "GenericName[%s]".printf (locale))
                    ) {
                        continue;
                    }
                    if(!file.has_key ("Desktop Entry", "Exec")) {
                        continue;
                    }

                    if(file.has_key ("Desktop Entry", "GenericName")) {
                        applicationName = file.get_string ("Desktop Entry", "GenericName");
                    }
                    if(file.has_key ("Desktop Entry", "GenericName[%s]".printf(locale))) {
                        applicationName = file.get_string ("Desktop Entry", "GenericName[%s]".printf(locale));
                    }
                    if(file.has_key ("Desktop Entry", "Name")) {
                        applicationName = file.get_string ("Desktop Entry", "Name");
                    }
                    if(file.has_key ("Desktop Entry", "Name[%s]".printf(locale))) {
                        applicationName = file.get_string ("Desktop Entry", "Name[%s]".printf(locale));
                    }

                    action = file.get_string ("Desktop Entry", "Exec");
                    icon = file.get_string ("Desktop Entry", "Icon");

                    var app = new ApplicationItem();
                    app.icon = icon;
                    app.label = applicationName;
                    app.action = action;
                    app.desktopFilePath = fileName;
                    apps.add (app);
                }
            }

            change (apps);
            
        } catch(Error e) {
            error("Error in Discovery applet: %s", e.message);
        }

    }
    
}