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

        var nextSupplier = suppliers
            .FirstOrDefault(x => x.Status == "Pending");

        if (nextSupplier != null)
        {
            nextSupplier.Status = "Next";
        }

        // Temporary route distance
        // Later we can calculate this using Haversine + Dijkstra
        double totalDistance = 18.5;

        return Ok(new
        {
            totalDistance = totalDistance,
            suppliers = suppliers
        });
    }
}