using Microsoft.EntityFrameworkCore;
using backend_dotnet.Models;

namespace backend_dotnet.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Supplier> Suppliers => Set<Supplier>();
    public DbSet<Collection> Collections => Set<Collection>();
}