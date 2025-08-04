public class WeatherCondition {
    public DateTime date { get; set; }
    public string tempC { get; set; }
    public string mintempC { get; set; }
    public string maxtempC { get; set; }
    public string weatherDesc { get; set; }
    public string weatherCode { get; set; }
    public string humidity { get; set; }
    public string pressure { get; set; }
    public string? weatherIconUrl { get; set; }
}