namespace backend_dotnet.Models;

public class CollectionRequest
{
    public string SupplierCode { get; set; } = string.Empty;
    public decimal ClearKg { get; set; }
    public decimal ColoredKg { get; set; }
    public string Condition { get; set; } = string.Empty;
}