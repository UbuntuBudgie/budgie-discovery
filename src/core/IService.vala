public interface IService {
    public abstract void start_service();
    public abstract void stop_service();
    public abstract void update_service(bool force);
}