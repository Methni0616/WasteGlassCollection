using System.ComponentModel.DataAnnotations.Schema;

namespace backend_dotnet.Models;

[Table("suppliers")]
public class Supplier
{
    [Column("id")]
    public int Id { get; set; }

    [Column("supplier_code")]
    public string SupplierCode { get; set; } = string.Empty;

    [Column("supplier_name")]
    public string SupplierName { get; set; } = string.Empty;

    [Column("latitude")]
    public decimal Latitude { get; set; }

    [Column("longitude")]
    public decimal Longitude { get; set; }

    [Column("expected_quantity")]
    public decimal ExpectedQuantity { get; set; }

    [Column("status")]
    public string Status { get; set; } = "Pending";
}