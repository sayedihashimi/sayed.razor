using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Buildings;

public class IndexModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public IndexModel(OfficeDataService dataService) => _dataService = dataService;

    public IReadOnlyList<Building> Buildings { get; set; } = [];
    public Dictionary<int, int> EmployeeCounts { get; set; } = [];
    public Dictionary<int, int> RoomCounts { get; set; } = [];

    public void OnGet()
    {
        Buildings = _dataService.GetAllBuildings();
        EmployeeCounts = Buildings.ToDictionary(b => b.Id, b => _dataService.GetEmployeesByBuilding(b.Id).Count);
        RoomCounts = Buildings.ToDictionary(b => b.Id, b => _dataService.GetRoomsByBuilding(b.Id).Count);
    }
}
