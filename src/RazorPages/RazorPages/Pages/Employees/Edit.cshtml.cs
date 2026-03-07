using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;
using System.Text.Json;

namespace RazorPages.Pages.Employees;

public class EditModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public EditModel(OfficeDataService dataService) => _dataService = dataService;

    [BindProperty]
    public Employee Employee { get; set; } = default!;

    public IReadOnlyList<Building> Buildings { get; set; } = [];
    public IReadOnlyList<Room> AllOfficeRooms { get; set; } = [];
    public IReadOnlyList<string> Departments { get; set; } = [];

    public string RoomsByBuildingJson { get; set; } = "{}";

    public IActionResult OnGet(int id)
    {
        var employee = _dataService.GetEmployeeById(id);
        if (employee is null) return NotFound();
        Employee = employee;
        LoadDropdownData();
        return Page();
    }

    public IActionResult OnPost()
    {
        if (!ModelState.IsValid)
        {
            LoadDropdownData();
            return Page();
        }
        _dataService.UpdateEmployee(Employee);
        return RedirectToPage("Details", new { id = Employee.Id });
    }

    private void LoadDropdownData()
    {
        Buildings = _dataService.GetAllBuildings();
        AllOfficeRooms = _dataService.GetAllRooms()
            .Where(r => r.Type == "Office")
            .OrderBy(r => r.RoomNumber)
            .ToList();
        Departments = _dataService.GetDepartments();

        var roomsByBuilding = AllOfficeRooms
            .GroupBy(r => r.BuildingId)
            .ToDictionary(
                g => g.Key.ToString(),
                g => g.Select(r => new { id = r.Id, roomNumber = r.RoomNumber }).ToList()
            );
        RoomsByBuildingJson = JsonSerializer.Serialize(roomsByBuilding);
    }
}
