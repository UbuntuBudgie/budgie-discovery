public class LocationItem: GLib.Object {
    public string? name {get; set;}
    public string? country {get; set;}
    public string? admin1 {get; set;}
    public string? admin2 {get; set;}
    public string? admin3 {get; set;}
    public string? admin4 {get; set;}
    public double? latitude {get;set;}
    public double? longitude {get;set;}
    
    public string? getDescription() {
        var admins = new Gee.ArrayList<string>();
        if (country != null && country.length > 0)
            admins.add(country);

        if (admin1 != null && admin1.length > 0)
            admins.add(admin1);

        if (admin2 != null && admin2.length > 0)
            admins.add(admin2);

        if (admin3 != null && admin3.length > 0)
            admins.add(admin3);

        if (admin4 != null && admin4.length > 0)
            admins.add(admin4);

        // UTF-8 Strings direkt verbinden
        string admin_text = "";
        bool first = true;
        foreach (var a in admins) {
            if (first) {
                admin_text += a;
                first = false;
            } else {
                admin_text += ", " + a;
            }
        }

        return admin_text;
    }
}