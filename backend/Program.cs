using System.Text.Json;
using System.Text.Json.Serialization;

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
        string idCidade = termo;

        if (!termo.All(char.IsDigit))
        {
            var searchUrl = $"https://brasilapi.com.br/api/cptec/v1/cidade/{Uri.EscapeDataString(termo)}";
            var cidades = await client.GetFromJsonAsync(searchUrl, AppJsonSerializerContext.Default.ListJsonElement);
            
            if (cidades == null || cidades.Count == 0) 
                return Results.Json(new ErrorResponse { erro = "Cidade nao encontrada" }, AppJsonSerializerContext.Default.ErrorResponse, statusCode: 404);

            idCidade = cidades[0].GetProperty("id").GetInt32().ToString();
        }

        var climaUrl = $"https://brasilapi.com.br/api/cptec/v1/clima/previsao/{idCidade}";
        var climaRes = await client.GetFromJsonAsync(climaUrl, AppJsonSerializerContext.Default.JsonElement);
        
        var previsaoHoje = climaRes.GetProperty("clima")[0];
        int tempMin = previsaoHoje.GetProperty("min").GetInt32();
        int tempMax = previsaoHoje.GetProperty("max").GetInt32();
        int tempAtual = (tempMin + tempMax) / 2;

        var resultado = new ClimaResponse
        {
            cidade = climaRes.GetProperty("cidade").GetString() ?? "",
            estado = climaRes.GetProperty("estado").GetString() ?? "",
            temperatura = tempAtual,
            temperatura_min = tempMin,
            temperatura_max = tempMax,
            condicao = previsaoHoje.GetProperty("condicao_desc").GetString() ?? "",
            condicao_code = previsaoHoje.GetProperty("condicao").GetString() ?? "",
            atualizado = climaRes.GetProperty("atualizado_em").GetString() ?? ""
        };

        return Results.Json(resultado, AppJsonSerializerContext.Default.ClimaResponse);
    }
    catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
    {
        return Results.Json(new ErrorResponse { erro = "Cidade nao encontrada ou dados indisponiveis" }, AppJsonSerializerContext.Default.ErrorResponse, statusCode: 404);
    }
    catch (Exception ex)
    {
        return Results.Json(new ErrorResponse { erro = "Falha ao buscar dados", detalhe = ex.Message }, AppJsonSerializerContext.Default.ErrorResponse, statusCode: 500);
    }
});

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
