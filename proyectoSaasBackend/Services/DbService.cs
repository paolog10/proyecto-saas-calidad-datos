using System.Data;
using Microsoft.Data.SqlClient;

namespace proyectoSaasBackend.Services
{
    public class DbService
    {
        private readonly string _connectionString;

        public DbService(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("DefaultConnection");
        }

        public async Task<string> EjecutarSP(string spName)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand(spName, conn);

            cmd.CommandType = CommandType.StoredProcedure;

            await conn.OpenAsync();

            var result = await cmd.ExecuteScalarAsync();

            return result?.ToString() ?? "{}";
        }
    }
}
