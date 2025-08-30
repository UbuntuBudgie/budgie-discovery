public class FeedRepository {
    private static FeedRepository instance = null;

    public signal void feedUpdated(string content);

    public static FeedRepository getInstance() {
        if(instance == null) {
            instance = new FeedRepository();
        }
        return instance;
    }
}