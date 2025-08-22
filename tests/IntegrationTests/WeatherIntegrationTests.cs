using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

public class WeatherEndpointTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public WeatherEndpointTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            // Avoid HTTPS redirect causing 30x in tests if https redirection is enabled
            AllowAutoRedirect = true
        });
    }

    [Fact]
    public async Task GET_weatherforecast_returns_ok()
    {
        var resp = await _client.GetAsync("/weatherforecast");
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode);
    }
}
