using Microsoft.AspNetCore.Mvc;
using backend_dotnet.Data;
using backend_dotnet.Models;
using Microsoft.EntityFrameworkCore;

namespace backend_dotnet.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CollectionController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public CollectionController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> SubmitCollection(CollectionRequest request)
    {
        var supplier = await _context.Suppliers
            .FirstOrDefaultAsync(s => s.SupplierCode == request.SupplierCode);

        if (supplier == null)
            return NotFound("Supplier not found");

        var collection = new Collection
        {
            SupplierCode = request.SupplierCode,
            ClearKg = request.ClearKg,
            ColoredKg = request.ColoredKg,
            Condition = request.Condition,
            CollectedAt = DateTime.UtcNow
        };

        _context.Collections.Add(collection);

        supplier.Status = "Collected";

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Collection saved successfully"
        });
    }
}