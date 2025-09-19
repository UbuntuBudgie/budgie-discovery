using Gee;
using GLib;

/* TODO generate applications cache file: generate appId to support favorites */

public class ApplicationService: IService {
    private static string cachePath;

    public signal void change(ArrayList<ApplicationItem> apps);

    public ApplicationService() {
        cachePath = "%s/cache".printf(Environment.get_user_runtime_dir ());
        GLib.DirUtils.create_with_parents (cachePath, 0700);
    }

    public void start_service () {
        update_service (false);
    }

    public void stop_service () {
        assert_not_reached ();
    }

    public void update_service (bool force) {
        if (!GLib.FileUtils.test(cachePath, GLib.FileTest.IS_DIR)) {
            return;
        }

        var cacheFile = "%s/appications.json".printf(cachePath);
        ArrayList<ApplicationItem> apps = new ArrayList<ApplicationItem>();
        ArrayList<string> files = new ArrayList<string>();
        ArrayList<string> json = new ArrayList<string>();

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
                    app.id = Uuid.string_random ();
                    apps.add (app);
                    json.add (app.toString ());
                }
            }

            FileUtils.set_contents (cacheFile, string.joinv(",",json.to_array ()));
            change (apps);
            
        } catch(Error e) {
            error("Error in Discovery applet: %s", e.message);
        }

    }
    
}