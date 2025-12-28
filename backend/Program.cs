using System.Text.Json;
using System.Text.Json.Serialization;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHttpClient();
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonSerializerContext.Default);
});

var app = builder.Build();
app.UseCors();

app.MapGet("/clima", async (string busca, IHttpClientFactory clientFactory) =>
{
    var client = clientFactory.CreateClient();
    string termo = busca.Trim();

    try
    {
        var geocodeUrl = $"https://geocoding-api.open-meteo.com/v1/search?name={Uri.EscapeDataString(termo)}&count=1&language=pt&format=json";
        var geocodeRes = await client.GetFromJsonAsync(geocodeUrl, AppJsonSerializerContext.Default.JsonElement);
        
        if (!geocodeRes.TryGetProperty("results", out var results) || results.GetArrayLength() == 0)
        {
            return Results.Json(new ErrorResponse { erro = "Cidade nao encontrada" }, AppJsonSerializerContext.Default.ErrorResponse, statusCode: 404);
        }
        
        var cidade = results[0];
        double latitude = cidade.GetProperty("latitude").GetDouble();
        double longitude = cidade.GetProperty("longitude").GetDouble();
        string nomeCidade = cidade.GetProperty("name").GetString() ?? "";
        string estado = cidade.TryGetProperty("admin1", out var admin1) ? admin1.GetString() ?? "" : "";
        
        var weatherUrl = $"https://api.open-meteo.com/v1/forecast?latitude={latitude.ToString(CultureInfo.InvariantCulture)}&longitude={longitude.ToString(CultureInfo.InvariantCulture)}&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min&timezone=America/Sao_Paulo&forecast_days=1";
        var weatherRes = await client.GetFromJsonAsync(weatherUrl, AppJsonSerializerContext.Default.JsonElement);
        
        var current = weatherRes.GetProperty("current");
        var daily = weatherRes.GetProperty("daily");
        
        double temp = current.GetProperty("temperature_2m").GetDouble();
        int weatherCode = current.GetProperty("weather_code").GetInt32();
        double tempMax = daily.GetProperty("temperature_2m_max")[0].GetDouble();
        double tempMin = daily.GetProperty("temperature_2m_min")[0].GetDouble();
        
        var resultado = new ClimaResponse
        {
            cidade = nomeCidade,
            estado = estado,
            temperatura = (int)Math.Round(temp),
            temperatura_min = (int)Math.Round(tempMin),
            temperatura_max = (int)Math.Round(tempMax),
            condicao = GetWeatherDescription(weatherCode),
            condicao_code = GetWeatherCode(weatherCode),
            atualizado = DateTime.Now.ToString("yyyy-MM-dd")
        };

        return Results.Json(resultado, AppJsonSerializerContext.Default.ClimaResponse);
    }
    catch (HttpRequestException)
    {
        return Results.Json(new ErrorResponse { erro = "Cidade nao encontrada ou dados indisponiveis" }, AppJsonSerializerContext.Default.ErrorResponse, statusCode: 404);
    }
    catch (Exception ex)
    {
        return Results.Json(new ErrorResponse { erro = "Falha ao buscar dados", detalhe = ex.Message }, AppJsonSerializerContext.Default.ErrorResponse, statusCode: 500);
    }
});

string GetWeatherDescription(int code)
{
    return code switch
    {
        0 => "Céu Limpo",
        1 => "Predominantemente Limpo",
        2 => "Parcialmente Nublado",
        3 => "Nublado",
        45 or 48 => "Neblina",
        51 or 53 or 55 => "Chuvisco",
        61 or 63 or 65 => "Chuva",
        71 or 73 or 75 => "Neve",
        77 => "Granizo",
        80 or 81 or 82 => "Pancadas de Chuva",
        85 or 86 => "Pancadas de Neve",
        95 => "Tempestade",
        96 or 99 => "Tempestade com Granizo",
        _ => "Desconhecido"
    };
}

string GetWeatherCode(int code)
{
    return code switch
    {
        0 => "c",
        1 => "c",
        2 => "pc",
        3 => "n",
        45 or 48 => "v",
        51 or 53 or 55 => "pp",
        61 or 63 or 65 => "pm",
        71 or 73 or 75 => "e",
        77 => "g",
        80 or 81 or 82 => "ch",
        85 or 86 => "e",
        95 => "t",
        96 or 99 => "g",
        _ => "n"
    };
}

app.Run();

public record ClimaResponse
{
    public string cidade { get; init; } = "";
    public string estado { get; init; } = "";
    public int temperatura { get; init; }
    public int temperatura_min { get; init; }
    public int temperatura_max { get; init; }
    public string condicao { get; init; } = "";
    public string condicao_code { get; init; } = "";
    public string atualizado { get; init; } = "";
}

public record ErrorResponse
{
    public string erro { get; init; } = "";
    public string? detalhe { get; init; }
}

[JsonSerializable(typeof(ClimaResponse))]
[JsonSerializable(typeof(ErrorResponse))]
[JsonSerializable(typeof(JsonElement))]
[JsonSerializable(typeof(List<JsonElement>))]
[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
public partial class AppJsonSerializerContext : JsonSerializerContext
{
}
