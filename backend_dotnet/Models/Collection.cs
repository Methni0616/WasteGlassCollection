using System.ComponentModel.DataAnnotations.Schema;

namespace backend_dotnet.Models;

[Table("collections")]
public class Collection
{
    [Column("id")]
    public int Id { get; set; }

    [Column("supplier_code")]
    public string SupplierCode { get; set; } = string.Empty;

    [Column("clear_kg")]
    public decimal ClearKg { get; set; }

    [Column("colored_kg")]
    public decimal ColoredKg { get; set; }

    [Column("condition")]
    public string Condition { get; set; } = string.Empty;

    [Column("collected_at")]
    public DateTime CollectedAt { get; set; }

}