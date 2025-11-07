using Microsoft.EntityFrameworkCore;
using AutoTTU.Connection;
using AutoTTU.Repository;
using AutoTTU.Service;
using System.Reflection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.AspNetCore.Mvc.Versioning;
using AutoTTU.ML.ServicesML;
using Microsoft.EntityFrameworkCore.InMemory;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();


builder.Services.AddSwaggerGen(c =>
{
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    c.IncludeXmlComments(xmlPath);
    
    // Configuração de segurança para API KEY
    c.AddSecurityDefinition("ApiKey", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Description = "API Key necessária para acessar os endpoints. Insira sua API Key no campo abaixo.",
        Name = "X-API-Key",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "ApiKeyScheme"
    });
    
    // Adiciona a segurança globalmente a todos os endpoints
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "ApiKey"
                }
            },
            Array.Empty<string>()
        }
    });
});



// Versionamento da API

builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0); // versão padrão
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true; // mostra no header da resposta quais versões existem
    options.ApiVersionReader = ApiVersionReader.Combine(
        new QueryStringApiVersionReader("api-version"), // ex: ?api-version=1.0
        new HeaderApiVersionReader("x-api-version"),    // ex: Header x-api-version: 1.0
        new UrlSegmentApiVersionReader()                // ex: /api/v1/usuarios
    );
});

// Permite que o Swagger reconheça as versões da API
builder.Services.AddVersionedApiExplorer(options =>
{
    options.GroupNameFormat = "'v'VVV"; // exibe como v1, v2
    options.SubstituteApiVersionInUrl = true;
});

// Banco de dados
builder.Services.AddDbContext<AppDbContext>(options =>
{
    // Em ambiente de testes, usa banco InMemory (fake)
    // Em produção, usa SQL Server
    if (builder.Environment.IsEnvironment("Testing"))
    {
        options.UseInMemoryDatabase($"TestDb_{System.Guid.NewGuid()}");
    }
    else
    {
        options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    }
});

// Registro dos Repositórios
builder.Services.AddScoped<IUsuarioRepository, UsuarioRepository>();
builder.Services.AddScoped<IMotosRepository, MotosRepository>();
builder.Services.AddScoped<ISlotRepository, SlotRepository>();
builder.Services.AddScoped<ICheckinRepository, CheckinRepository>();

// Registro dos Serviços
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<IMotosService, MotosService>();
builder.Services.AddScoped<ISlotService, SlotService>();
builder.Services.AddScoped<ICheckinService, CheckinService>();


// Health Checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>(
        name: "database",
        failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Unhealthy,
        tags: new[] { "db", "sql", "sqlserver" });

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowLocalhost", policy =>
    {
        policy.WithOrigins("http://localhost:8081") // ou a URL do seu app front
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowCors", policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

// Registro do Serviço de IA
builder.Services.AddScoped<IIAService, IAService>();


var app = builder.Build();

// Swagger 

var provider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        // Cria uma aba do Swagger para cada versão
        foreach (var description in provider.ApiVersionDescriptions)
        {
            options.SwaggerEndpoint($"/swagger/{description.GroupName}/swagger.json",
                $"AutoTTU API {description.GroupName.ToUpper()}");
        }
    });
}



app.UseHttpsRedirection();

app.UseCors("AllowCors");

app.UseMiddleware<AutoTTU.Middleware.ApiKeyMiddleware>();

app.UseAuthorization();

app.MapControllers();

// Health Check endpoints
app.MapHealthChecks("/health");

app.Run();

// Classe pública para permitir que WebApplicationFactory funcione com top-level statements
public partial class Program { }
