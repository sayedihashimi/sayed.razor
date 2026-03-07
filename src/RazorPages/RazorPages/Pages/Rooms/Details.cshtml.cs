using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Rooms;

public class DetailsModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public DetailsModel(OfficeDataService dataService) => _dataService = dataService;

    public Room Room { get; set; } = default!;
    public Building Building { get; set; } = default!;
    public Employee? AssignedEmployee { get; set; }

    public IActionResult OnGet(int id)
    {
        var room = _dataService.GetRoomById(id);
        if (room is null) return NotFound();

        Room = room;
        Building = _dataService.GetBuildingById(room.BuildingId)!;
        AssignedEmployee = room.AssignedEmployeeId.HasValue
            ? _dataService.GetEmployeeById(room.AssignedEmployeeId.Value)
            : null;
        return Page();
    }
}
