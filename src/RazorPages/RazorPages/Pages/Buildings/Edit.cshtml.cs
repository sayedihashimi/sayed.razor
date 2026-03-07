using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages.Buildings;

public class EditModel : PageModel
{
    private readonly OfficeDataService _dataService;

    public EditModel(OfficeDataService dataService) => _dataService = dataService;

    [BindProperty]
    public Building Building { get; set; } = default!;

    public IActionResult OnGet(int id)
    {
        var building = _dataService.GetBuildingById(id);
        if (building is null) return NotFound();
        Building = building;
        return Page();
    }

    public IActionResult OnPost()
    {
        if (!ModelState.IsValid) return Page();
        _dataService.UpdateBuilding(Building);
        return RedirectToPage("Details", new { id = Building.Id });
    }
}
