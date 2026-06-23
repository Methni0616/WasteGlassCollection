using Microsoft.AspNetCore.Mvc;
using backend_dotnet.Data;
using Microsoft.EntityFrameworkCore;

namespace backend_dotnet.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RouteController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public RouteController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetRoute()
    {
        var suppliers = await _context.Suppliers
            .OrderBy(s => s.Id)
            .ToListAsync();

        return Ok(suppliers);
    }
}