using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Buildings;

public class DetailsModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public DetailsModel(OfficeDataService dataService) => _dataService = dataService;

    public Building Building { get; set; } = default!;
    public IReadOnlyList<Room> Rooms { get; set; } = [];
    public IReadOnlyList<Employee> Employees { get; set; } = [];
    public Dictionary<int, List<Room>> RoomsByFloor { get; set; } = [];

    public IActionResult OnGet(int id)
    {
        var building = _dataService.GetBuildingById(id);
        if (building is null) return NotFound();

        Building = building;
        Rooms = _dataService.GetRoomsByBuilding(id);
        Employees = _dataService.GetEmployeesByBuilding(id);
        RoomsByFloor = Rooms.GroupBy(r => r.Floor)
            .OrderBy(g => g.Key)
            .ToDictionary(g => g.Key, g => g.OrderBy(r => r.RoomNumber).ToList());
        return Page();
    }

    public string GetEmployeeName(int? employeeId)
    {
        if (employeeId is null) return "—";
        var emp = _dataService.GetEmployeeById(employeeId.Value);
        return emp?.FullName ?? "—";
    }
}
