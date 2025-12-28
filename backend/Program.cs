using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHttpClient();
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

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
            var cidades = await client.GetFromJsonAsync<List<JsonElement>>(searchUrl);
            
            if (cidades == null || cidades.Count == 0) 
                return Results.NotFound(new { erro = "Cidade nao encontrada" });

            idCidade = cidades[0].GetProperty("id").GetInt32().ToString();
        }

        var climaUrl = $"https://brasilapi.com.br/api/cptec/v1/clima/previsao/{idCidade}";
        var climaRes = await client.GetFromJsonAsync<JsonElement>(climaUrl);
        
        var previsaoHoje = climaRes.GetProperty("clima")[0];
        int tempMin = previsaoHoje.GetProperty("min").GetInt32();
        int tempMax = previsaoHoje.GetProperty("max").GetInt32();
        int tempAtual = (tempMin + tempMax) / 2;

        return Results.Ok(new
        {
            cidade = climaRes.GetProperty("cidade").GetString(),
            estado = climaRes.GetProperty("estado").GetString(),
            temperatura = tempAtual,
            temperatura_min = tempMin,
            temperatura_max = tempMax,
            condicao = previsaoHoje.GetProperty("condicao_desc").GetString(),
            condicao_code = previsaoHoje.GetProperty("condicao").GetString(),
            atualizado = climaRes.GetProperty("atualizado_em").GetString()
        });
    }
    catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
    {
        return Results.NotFound(new { erro = "Cidade nao encontrada ou dados indisponiveis" });
    }
    catch (Exception ex)
    {
        return Results.Json(new { erro = "Falha ao buscar dados", detalhe = ex.Message }, statusCode: 500);
    }
});

app.Run();
