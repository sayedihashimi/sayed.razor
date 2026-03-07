using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Rooms;

public class EditModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public EditModel(OfficeDataService dataService) => _dataService = dataService;

    [BindProperty]
    public Room Room { get; set; } = default!;

    public Building Building { get; set; } = default!;
    public IReadOnlyList<Employee> AvailableEmployees { get; set; } = [];

    public IActionResult OnGet(int id)
    {
        var room = _dataService.GetRoomById(id);
        if (room is null) return NotFound();
        Room = room;
        LoadPageData();
        return Page();
    }

    public IActionResult OnPost()
    {
        if (!ModelState.IsValid)
        {
            LoadPageData();
            return Page();
        }
        _dataService.UpdateRoom(Room);
        return RedirectToPage("Details", new { id = Room.Id });
    }

    private void LoadPageData()
    {
        Building = _dataService.GetBuildingById(Room.BuildingId)!;
        // Show employees in this building who are unassigned or currently assigned to this room
        AvailableEmployees = _dataService.GetEmployeesByBuilding(Room.BuildingId)
            .Where(e => e.RoomId == Room.Id || !_dataService.GetAllRooms()
                .Any(r => r.AssignedEmployeeId == e.Id && r.Id != Room.Id))
            .OrderBy(e => e.FullName)
            .ToList();
    }
}
