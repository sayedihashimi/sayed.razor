using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Rooms;

public class IndexModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public IndexModel(OfficeDataService dataService) => _dataService = dataService;

    public IReadOnlyList<Room> Rooms { get; set; } = [];
    public IReadOnlyList<Building> Buildings { get; set; } = [];

    [BindProperty(SupportsGet = true)]
    public int? BuildingId { get; set; }

    [BindProperty(SupportsGet = true)]
    public int? Floor { get; set; }

    [BindProperty(SupportsGet = true)]
    public string? RoomType { get; set; }

    public void OnGet()
    {
        Buildings = _dataService.GetAllBuildings();
        var rooms = _dataService.GetAllRooms().AsEnumerable();

        if (BuildingId.HasValue)
            rooms = rooms.Where(r => r.BuildingId == BuildingId.Value);
        if (Floor.HasValue)
            rooms = rooms.Where(r => r.Floor == Floor.Value);
        if (!string.IsNullOrEmpty(RoomType))
            rooms = rooms.Where(r => r.Type.Equals(RoomType, StringComparison.OrdinalIgnoreCase));

        Rooms = rooms.OrderBy(r => r.RoomNumber).ToList();
    }

    public string GetBuildingName(int buildingId) => _dataService.GetBuildingName(buildingId);

    public string GetEmployeeName(int? employeeId)
    {
        if (employeeId is null) return "—";
        return _dataService.GetEmployeeById(employeeId.Value)?.FullName ?? "—";
    }
}
