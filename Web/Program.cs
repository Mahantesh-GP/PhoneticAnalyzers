using PhoneticAnalyzers.Web.Components;
using PhoneticAnalyzers.Web.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// Configure HTTP client for API service
builder.Services.AddHttpClient<PhoneticAnalyzersApiService>(client =>
{
    // Configure base address for the API
    var apiBaseAddress = builder.Configuration["ApiSettings:BaseAddress"] ?? "http://localhost:7071";
    client.BaseAddress = new Uri(apiBaseAddress);
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Add additional services
builder.Services.AddScoped<PhoneticAnalyzersApiService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
