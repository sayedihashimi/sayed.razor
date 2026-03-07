namespace RazorPages.Models;

public class Building
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = "Redmond";
    public string State { get; set; } = "WA";
    public string ZipCode { get; set; } = "98052";
    public int Floors { get; set; }
    public int YearBuilt { get; set; }
    public string Phone { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string PrimaryDepartments { get; set; } = string.Empty;
}
