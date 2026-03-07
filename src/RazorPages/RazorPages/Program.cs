var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddSingleton<RazorPages.Services.OfficeDataService>();
builder.Services.AddRazorPages();

var app = builder.Build();

// Eagerly initialize the data service to load seed data at startup
app.Services.GetRequiredService<RazorPages.Services.OfficeDataService>();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();
app.MapRazorPages()
   .WithStaticAssets();

app.Run();
