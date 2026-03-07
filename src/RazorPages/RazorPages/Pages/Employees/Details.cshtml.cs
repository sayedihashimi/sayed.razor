using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Employees;

public class DetailsModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public DetailsModel(OfficeDataService dataService) => _dataService = dataService;

    public Employee Employee { get; set; } = default!;
    public Building Building { get; set; } = default!;
    public Room Room { get; set; } = default!;

    public IActionResult OnGet(int id)
    {
        var employee = _dataService.GetEmployeeById(id);
        if (employee is null) return NotFound();

        Employee = employee;
        Building = _dataService.GetBuildingById(employee.BuildingId)!;
        Room = _dataService.GetRoomById(employee.RoomId)!;
        return Page();
    }
}
