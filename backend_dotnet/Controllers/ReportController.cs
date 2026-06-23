using Microsoft.AspNetCore.Mvc;
using backend_dotnet.Data;
using Microsoft.EntityFrameworkCore;

namespace backend_dotnet.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReportController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public ReportController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetReport()
    {
        var collections = await _context.Collections.ToListAsync();

        var totalClear = collections.Sum(x => x.ClearKg);
        var totalColored = collections.Sum(x => x.ColoredKg);

        var totalCollected = totalClear + totalColored;

        var supplierCount = await _context.Suppliers.CountAsync();

        var collectedCount = await _context.Suppliers
            .CountAsync(x => x.Status == "Collected");

        return Ok(new
        {
            totalSuppliers = supplierCount,
            collectedSuppliers = collectedCount,
            totalClearKg = totalClear,
            totalColoredKg = totalColored,
            totalCollectedKg = totalCollected
        });
    }
}