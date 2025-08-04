public class WeatherForecast: WeatherCondition {
    public WeatherAstronomy astronomy { get; set; }
    public unowned List<WeatherCondition> hourlyForecast { get; set; }
}