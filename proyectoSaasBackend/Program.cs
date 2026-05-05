using proyectoSaasBackend.Services;

namespace proyectoSaasBackend
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            
            //SERVICIOS
            builder.Services.AddScoped<DbService>();
            builder.Services.AddControllers();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll",
                    policy => policy
                        .AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
            });

            //BUILD
            var app = builder.Build();

            //MIDDLEWARES
            app.UseCors("AllowAll");

            app.UseSwagger();
            app.UseSwaggerUI();

            app.MapControllers();

            //RUN
            app.Run();

        }
    }
}
