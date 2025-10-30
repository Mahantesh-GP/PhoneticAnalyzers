using Newtonsoft.Json;

namespace PhoneticAnalyzers.Web.Services;

/// <summary>
/// API client service for PhoneticAnalyzers backend
/// </summary>
public class PhoneticAnalyzersApiService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<PhoneticAnalyzersApiService> _logger;

    public PhoneticAnalyzersApiService(HttpClient httpClient, ILogger<PhoneticAnalyzersApiService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    /// <summary>
    /// Health check endpoint
    /// </summary>
    public async Task<HealthCheckResult?> HealthCheckAsync()
    {
        try
        {
            var response = await _httpClient.GetAsync("/api/health");
            response.EnsureSuccessStatusCode();
            
            var content = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<HealthCheckResult>(content);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Health check failed");
            return null;
        }
    }

    /// <summary>
    /// Add a single person
    /// </summary>
    public async Task<PersonIngestResult?> AddPersonAsync(PersonData personData)
    {
        try
        {
            var json = JsonConvert.SerializeObject(personData);
            var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
            
            var response = await _httpClient.PostAsync("/api/ingest", content);
            response.EnsureSuccessStatusCode();
            
            var responseContent = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<PersonIngestResult>(responseContent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to add person: {ExternalId}", personData.ExternalId);
            throw;
        }
    }

    /// <summary>
    /// Search for persons using phonetic matching
    /// </summary>
    public async Task<SearchResult?> SearchPersonsAsync(string name, int maxResults = 10)
    {
        try
        {
            var response = await _httpClient.GetAsync($"/api/search?name={Uri.EscapeDataString(name)}&maxResults={maxResults}");
            response.EnsureSuccessStatusCode();
            
            var content = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<SearchResult>(content);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to search persons with name: {Name}", name);
            throw;
        }
    }

    /// <summary>
    /// Batch add multiple persons
    /// </summary>
    public async Task<BatchIngestResult?> AddPersonsBatchAsync(List<PersonData> persons)
    {
        try
        {
            var batchData = new { persons };
            var json = JsonConvert.SerializeObject(batchData);
            var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
            
            var response = await _httpClient.PostAsync("/api/ingest/batch", content);
            response.EnsureSuccessStatusCode();
            
            var responseContent = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<BatchIngestResult>(responseContent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to batch add {Count} persons", persons.Count);
            throw;
        }
    }

    /// <summary>
    /// Get person by ID
    /// </summary>
    public async Task<PersonDetails?> GetPersonAsync(string id)
    {
        try
        {
            var response = await _httpClient.GetAsync($"/api/person/{Uri.EscapeDataString(id)}");
            response.EnsureSuccessStatusCode();
            
            var content = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<PersonDetails>(content);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get person: {Id}", id);
            throw;
        }
    }
}

// Data Transfer Objects
public class PersonData
{
    public string ExternalId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public bool ExpandNicknames { get; set; } = true;
}

public class PersonIngestResult
{
    public long PersonId { get; set; }
    public string Message { get; set; } = string.Empty;
    public bool WasCreated { get; set; }
    public PhoneticCodes PhoneticCodes { get; set; } = new();
    public List<string> Warnings { get; set; } = new();
}

public class PhoneticCodes
{
    public string? Primary { get; set; }
    public string? Alternate { get; set; }
    public List<string> BeiderMorseCodes { get; set; } = new();
}

public class SearchResult
{
    public string Query { get; set; } = string.Empty;
    public int TotalResults { get; set; }
    public int MaxResults { get; set; }
    public double ExecutionTime { get; set; }
    public List<PersonSearchResult> Results { get; set; } = new();
}

public class PersonSearchResult
{
    public long PersonId { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string NormalizedName { get; set; } = string.Empty;
    public double SimilarityScore { get; set; }
    public string MatchType { get; set; } = string.Empty;
    public PersonPhoneticCodes? PhoneticCodes { get; set; }
}

public class PersonPhoneticCodes
{
    public DoubleMetaphoneCodes DoubleMetaphone { get; set; } = new();
    public List<string> BeiderMorse { get; set; } = new();
}

public class DoubleMetaphoneCodes
{
    public string? Primary { get; set; }
    public string? Alternate { get; set; }
}

public class BatchIngestResult
{
    public int TotalProcessed { get; set; }
    public int Successful { get; set; }
    public int Failed { get; set; }
    public List<BatchResultItem> Results { get; set; } = new();
    public List<BatchResultItem> Errors { get; set; } = new();
}

public class BatchResultItem
{
    public string ExternalId { get; set; } = string.Empty;
    public long? PersonId { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? Error { get; set; }
}

public class HealthCheckResult
{
    public string Status { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string Version { get; set; } = string.Empty;
}

public class PersonDetails
{
    public long PersonId { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string NormalizedName { get; set; } = string.Empty;
    public DateTime CreatedUtc { get; set; }
    public PersonPhoneticCodes? PhoneticCodes { get; set; }
}