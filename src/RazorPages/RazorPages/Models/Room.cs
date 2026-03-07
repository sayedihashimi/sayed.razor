namespace RazorPages.Models;

public class Room
{
    public int Id { get; set; }
    public int BuildingId { get; set; }
    public int Floor { get; set; }
    public string RoomNumber { get; set; } = string.Empty;
    public string Type { get; set; } = "Office";
    public int Capacity { get; set; } = 1;
    public bool HasWindow { get; set; }
    public string? Notes { get; set; }
    public int? AssignedEmployeeId { get; set; }
}
