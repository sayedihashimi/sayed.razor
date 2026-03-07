using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages;

public class IndexModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public IndexModel(OfficeDataService dataService)
    {
        _dataService = dataService;
    }

    public int TotalBuildings { get; set; }
    public int TotalEmployees { get; set; }
    public int TotalRooms { get; set; }
    public int OccupiedOffices { get; set; }
    public int AvailableOffices { get; set; }
    public IReadOnlyList<Building> Buildings { get; set; } = [];
    public Dictionary<int, int> EmployeeCountByBuilding { get; set; } = [];

    public void OnGet()
    {
        TotalBuildings = _dataService.TotalBuildings;
        TotalEmployees = _dataService.TotalEmployees;
        TotalRooms = _dataService.TotalRooms;
        OccupiedOffices = _dataService.OccupiedOffices;
        AvailableOffices = _dataService.AvailableOffices;
        Buildings = _dataService.GetAllBuildings();
        EmployeeCountByBuilding = Buildings.ToDictionary(
            b => b.Id,
            b => _dataService.GetEmployeesByBuilding(b.Id).Count
        );
    }
}
