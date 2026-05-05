using Microsoft.AspNetCore.Mvc;
using proyectoSaasBackend.Services;

[ApiController]
[Route("api/clientes")]
public class ClientesController : ControllerBase
{
    private readonly DbService _db;

    public ClientesController(DbService db)
    {
        _db = db;
    }

    [HttpGet("analizar")]
    public async Task<IActionResult> Analizar()
    {
        var result = await _db.EjecutarSP("AnalizarClientesExcelFerreteriaTipada");
        return Ok(result);
    }

    [HttpGet("sanitizar")]
    public async Task<IActionResult> Sanitizar()
    {
        var result = await _db.EjecutarSP("SanitizarClientesExcelFerreteriaTipada");
        return Ok(result);
    }
}
