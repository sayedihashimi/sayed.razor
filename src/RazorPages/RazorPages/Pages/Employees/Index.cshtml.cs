using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Employees;

public class IndexModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public IndexModel(OfficeDataService dataService) => _dataService = dataService;

    public IReadOnlyList<Employee> Employees { get; set; } = [];
    public IReadOnlyList<Building> Buildings { get; set; } = [];
    public IReadOnlyList<string> Departments { get; set; } = [];

    [BindProperty(SupportsGet = true)]
    public string? Search { get; set; }

    [BindProperty(SupportsGet = true)]
    public int? BuildingId { get; set; }

    [BindProperty(SupportsGet = true)]
    public string? Department { get; set; }

    public void OnGet()
    {
        Buildings = _dataService.GetAllBuildings();
        Departments = _dataService.GetDepartments();

        var employees = _dataService.GetAllEmployees().AsEnumerable();

        if (!string.IsNullOrWhiteSpace(Search))
            employees = employees.Where(e =>
                e.FullName.Contains(Search, StringComparison.OrdinalIgnoreCase) ||
                e.Email.Contains(Search, StringComparison.OrdinalIgnoreCase));
        if (BuildingId.HasValue)
            employees = employees.Where(e => e.BuildingId == BuildingId.Value);
        if (!string.IsNullOrEmpty(Department))
            employees = employees.Where(e => e.Department.Equals(Department, StringComparison.OrdinalIgnoreCase));

        Employees = employees.OrderBy(e => e.LastName).ThenBy(e => e.FirstName).ToList();
    }

    public string GetBuildingName(int buildingId) => _dataService.GetBuildingName(buildingId);
    public string GetRoomNumber(int roomId) => _dataService.GetRoomNumber(roomId);
}
