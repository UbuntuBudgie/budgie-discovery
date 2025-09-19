public class ApplicationItem {
    public string label {get; set;}
    public string icon {get; set;}
    public string action {get; set;}
    public string desktopFilePath {get; set;}

    public string toString() {
        return "{\"label\": \"%s\", \"action\": \"%s\", \"icon\": \"%s\", \"desktopFilePath\": \"%s\"}"
            .printf(label, action, icon,desktopFilePath);
    }
}