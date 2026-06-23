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

        var firstCollection = collections
    .OrderBy(x => x.CollectedAt)
    .FirstOrDefault();

        var lastCollection = collections
            .OrderByDescending(x => x.CollectedAt)
            .FirstOrDefault();

        string tripDuration = "0 Minutes";

        if (firstCollection != null && lastCollection != null)
        {
            var minutes = (lastCollection.CollectedAt - firstCollection.CollectedAt)
                .TotalMinutes;

            tripDuration = $"{Math.Round(minutes)} Minutes";
        }

        var supplierCount = await _context.Suppliers.CountAsync();

        var collectedCount = await _context.Suppliers
            .CountAsync(x => x.Status == "Collected");

        var supplierDetails = await _context.Suppliers
    .Select(s => new
    {
        supplierCode = s.SupplierCode,
        supplierName = s.SupplierName,
        expectedQuantity = s.ExpectedQuantity,

        collectedQuantity =
            _context.Collections
                .Where(c => c.SupplierCode == s.SupplierCode)
                .Sum(c => (decimal?)(
                    c.ClearKg + c.ColoredKg
                )) ?? 0,

        status = s.Status
    })
    .ToListAsync();

        return Ok(new
        {
            totalSuppliers = supplierCount,
            collectedSuppliers = collectedCount,
            totalClearKg = totalClear,
            totalColoredKg = totalColored,
            totalCollectedKg = totalCollected,
            tripDuration = tripDuration,

            suppliers = supplierDetails
        });
    }
}