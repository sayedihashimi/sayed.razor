# Update RazorPages App to Cascade Innovations Office Manager

Transform the default ASP.NET Core Razor Pages app at `src/RazorPages/RazorPages/` into **Cascade Innovations Office Manager** — a demo office management application for a fictitious technology company headquartered in Redmond, WA. The company has 6 office buildings and 350 employees. Every employee has their own private office. This is a demo app — all data is loaded from a JSON seed file at startup and subsequent changes are stored in memory only.

- **Project path:** `src/RazorPages/RazorPages/`
- **Company name:** Cascade Innovations
- **Headquarters:** Redmond, WA
- **Buildings:** 6 office buildings
- **Total employees:** 350
- **Data storage:** In-memory (loaded from JSON seed file at startup; changes are in-memory only)
- **Styling:** Tailwind CSS via CDN (`https://cdn.tailwindcss.com`)
- **Confirmations:** Custom Tailwind modal popup for important edits (building, room, employee changes)
- **Images:** No image files — use emoji for visual flair

---

## Company Overview

**Cascade Innovations** is a mid-size technology company specializing in cloud-based productivity software. Founded in 2012, the company has grown to 350 employees across 6 office buildings in the Redmond, WA area. The company is known for its collaborative culture and modern office spaces.

---

## Step 1: Create the Data Models

Create three model classes in the `Models/` folder.

### Models/Building.cs

```csharp
namespace RazorPages.Models;

public class Building
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = "Redmond";
    public string State { get; set; } = "WA";
    public string ZipCode { get; set; } = "98052";
    public int Floors { get; set; }
    public int YearBuilt { get; set; }
    public string Phone { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string PrimaryDepartments { get; set; } = string.Empty;
}
```

### Models/Room.cs

```csharp
namespace RazorPages.Models;

public class Room
{
    public int Id { get; set; }
    public int BuildingId { get; set; }
    public int Floor { get; set; }
    public string RoomNumber { get; set; } = string.Empty;
    public string Type { get; set; } = "Office";
    public int Capacity { get; set; } = 1;
    public bool HasWindow { get; set; }
    public string? Notes { get; set; }
    public int? AssignedEmployeeId { get; set; }
}
```

### Models/Employee.cs

```csharp
namespace RazorPages.Models;

public class Employee
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public DateTime HireDate { get; set; }
    public int BuildingId { get; set; }
    public int RoomId { get; set; }
    public string EmergencyContactName { get; set; } = string.Empty;
    public string EmergencyContactPhone { get; set; } = string.Empty;

    public string FullName => $"{FirstName} {LastName}";
}
```

---

## Step 2: Create the Seed Data JSON File

Create `Data/seed-data.json` in the project root (`src/RazorPages/RazorPages/Data/seed-data.json`). This single file contains all buildings, rooms, and employees.

### Building Data

Include exactly these 6 buildings:

| # | Code | Name | Address | Floors | Year Built | Phone | Primary Departments | Description |
|---|------|------|---------|--------|------------|-------|---------------------|-------------|
| 1 | A | Cascade Tower | 156 NE 40th St | 4 | 2015 | (425) 555-1001 | Engineering | Flagship engineering building. Open floor plan with dedicated focus pods. Rooftop terrace with views of the Cascades. Houses the largest engineering teams. |
| 2 | B | Evergreen Hall | 2001 152nd Ave NE | 3 | 2017 | (425) 555-1002 | Product Management, Design | Creative hub for product and design teams. Features collaboration spaces, whiteboard walls, and a user research lab. Named for the iconic Pacific NW evergreen trees. |
| 3 | C | Olympic Center | 8401 164th Ave NE | 3 | 2018 | (425) 555-1003 | Marketing, Sales | Commercial heart of Cascade Innovations. Home to marketing and sales with a modern demo center for client presentations. Named for the Olympic Mountains. |
| 4 | D | Rainier Pavilion | 3001 Willows Rd NE | 3 | 2016 | (425) 555-1004 | Finance, Legal | Houses finance, legal, and compliance teams. Quiet, professional environment with a law library and secure document storage. Named for Mount Rainier. |
| 5 | E | Puget Innovation Hub | 10900 NE 8th St | 4 | 2019 | (425) 555-1005 | Engineering, IT Operations | Secondary engineering campus with dedicated DevOps and IT infrastructure. Features a hardware prototyping lab and server monitoring center. |
| 6 | F | Baker Research Lab | 15200 NE 36th St | 2 | 2020 | (425) 555-1006 | Executive, Human Resources, Facilities | Executive offices and HR. Modern, sustainable design with LEED Gold certification. Includes the main boardroom and employee wellness center. |

All buildings share: City = "Redmond", State = "WA", ZipCode = "98052".

### Room Allocation

**Room numbering convention:** `{BuildingCode}-{Floor}{Sequential 2-digit}`, e.g., `A-101`, `A-102`, ..., `A-120`, `A-201`, etc.

**Room types and naming:**

- **Office** — capacity 1, for employee assignment
- **Conference Room** — capacity 8–12, named after Pacific NW peaks/landmarks: Rainier, Baker, Olympic, St. Helens, Adams, Hood, Glacier Peak, Shuksan, Stuart, Eldorado, Sahale, Cascade, Deception, Chelan, Diablo
- **Break Room** — capacity 15–20
- **Server Room**, **UX Lab**, **Demo Center**, **Records Room**, **Prototyping Lab**, **Executive Boardroom**, **Wellness Center** — specialty rooms, 1 per building as noted below

**HasWindow rules:** Corner offices (first and last office on each floor) always have windows. Alternate true/false for remaining offices.

### Room counts per building

| Building | Floors | Offices | Conference | Break | Other | Total |
|----------|--------|---------|------------|-------|-------|-------|
| Cascade Tower (A) | 4 | 75 | 4 | 4 | 1 (Server Room A-B01) | 84 |
| Evergreen Hall (B) | 3 | 55 | 3 | 3 | 1 (UX Lab B-S01) | 62 |
| Olympic Center (C) | 3 | 60 | 3 | 3 | 1 (Demo Center C-S01) | 67 |
| Rainier Pavilion (D) | 3 | 50 | 3 | 3 | 1 (Records Room D-S01) | 57 |
| Puget Innovation Hub (E) | 4 | 65 | 4 | 4 | 2 (Server Room E-B01, Prototyping Lab E-B02) | 75 |
| Baker Research Lab (F) | 2 | 45 | 2 | 2 | 2 (Executive Boardroom F-S01, Wellness Center F-S02) | 51 |

**Total rooms: 396 | Total offices: 350 (one per employee)**

### Employee Distribution

350 employees across 11 departments:

| Department | Count | Building Assignment(s) | Titles (use a mix) |
|------------|-------|------------------------|---------------------|
| Engineering | 100 | Cascade Tower (75), Puget Innovation Hub (25) | Software Engineer, Senior Software Engineer, Principal Engineer, Staff Engineer, Engineering Manager |
| Product Management | 30 | Evergreen Hall | Product Manager, Senior Product Manager, Group Product Manager, Director of Product |
| Design | 25 | Evergreen Hall | UX Designer, Senior UX Designer, Visual Designer, Design Lead, UX Researcher |
| Human Resources | 20 | Baker Research Lab | HR Specialist, HR Manager, Senior Recruiter, Benefits Coordinator, HR Director |
| Finance | 25 | Rainier Pavilion | Financial Analyst, Senior Financial Analyst, Accountant, Senior Accountant, Controller |
| Marketing | 35 | Olympic Center | Marketing Specialist, Content Strategist, Marketing Manager, Brand Manager, SEO Specialist, Social Media Manager |
| Sales | 40 | Olympic Center (25), Rainier Pavilion (10), Baker Research Lab (5) | Account Executive, Senior Account Executive, Sales Manager, Sales Director, Business Development Rep |
| Legal | 15 | Rainier Pavilion | Legal Counsel, Senior Legal Counsel, Paralegal, Compliance Officer, General Counsel |
| IT Operations | 30 | Puget Innovation Hub | Systems Administrator, Network Engineer, IT Support Specialist, DevOps Engineer, IT Manager, Cloud Architect |
| Executive | 10 | Baker Research Lab | CEO, COO, CTO, CFO, VP of Engineering, VP of Sales, VP of Marketing, VP of Product, VP of People, VP of Operations |
| Facilities | 20 | Baker Research Lab (10), Puget Innovation Hub (10) | Facilities Manager, Maintenance Technician, Security Officer, Receptionist, Office Coordinator |

**Total: 350 employees**

### Named Employees (include at minimum, generate the rest)

These are the key employees — include them exactly as specified, then generate the remaining employees to reach 350 total:

| # | First | Last | Department | Title | Building |
|---|-------|------|-----------|-------|----------|
| 1 | Sarah | Chen | Executive | CEO | Baker Research Lab |
| 2 | Marcus | Williams | Executive | CTO | Baker Research Lab |
| 3 | Priya | Patel | Executive | COO | Baker Research Lab |
| 4 | James | O'Brien | Executive | CFO | Baker Research Lab |
| 5 | Lisa | Nakamura | Executive | VP of Engineering | Baker Research Lab |
| 6 | Robert | Garcia | Executive | VP of Sales | Baker Research Lab |
| 7 | Amanda | Foster | Executive | VP of Marketing | Baker Research Lab |
| 8 | Daniel | Johansson | Executive | VP of Product | Baker Research Lab |
| 9 | Karen | Mitchell | Executive | VP of People | Baker Research Lab |
| 10 | Anthony | Brooks | Executive | VP of Operations | Baker Research Lab |
| 11 | David | Rodriguez | Engineering | Engineering Manager | Cascade Tower |
| 12 | Mei-Lin | Chang | Engineering | Principal Engineer | Cascade Tower |
| 13 | Arun | Krishnamurthy | Engineering | Staff Engineer | Cascade Tower |
| 14 | Jessica | Thompson | Engineering | Senior Software Engineer | Cascade Tower |
| 15 | Brian | Murphy | Engineering | Engineering Manager | Puget Innovation Hub |
| 16 | Emily | Washington | Product Management | Director of Product | Evergreen Hall |
| 17 | Michael | Kim | Design | Design Lead | Evergreen Hall |
| 18 | Rachel | Okafor | Marketing | Marketing Manager | Olympic Center |
| 19 | Thomas | Andersen | Sales | Sales Director | Olympic Center |
| 20 | Sofia | Martinez | Finance | Controller | Rainier Pavilion |
| 21 | William | Stewart | Legal | General Counsel | Rainier Pavilion |
| 22 | Natalie | Dubois | Human Resources | HR Director | Baker Research Lab |
| 23 | Kevin | Zhao | IT Operations | IT Manager | Puget Innovation Hub |
| 24 | Christine | Larsen | Facilities | Facilities Manager | Baker Research Lab |
| 25 | Omar | Hassan | Engineering | Senior Software Engineer | Cascade Tower |
| 26 | Ashley | Nguyen | Design | Senior UX Designer | Evergreen Hall |
| 27 | Samuel | Clark | Sales | Sales Manager | Olympic Center |
| 28 | Diana | Petrov | Legal | Senior Legal Counsel | Rainier Pavilion |
| 29 | Tyler | Bennett | IT Operations | Cloud Architect | Puget Innovation Hub |
| 30 | Maria | Santos | Marketing | Content Strategist | Olympic Center |

### Generation rules for remaining employees

1. **Names:** Use diverse, realistic first and last names. No duplicate full names.
2. **Email:** `{firstname}.{lastname}@cascadeinnovations.com` (lowercase, remove special chars like apostrophes)
3. **Phone:** `(425) 555-{4-digit}` — unique per employee, range 2001–2350
4. **Hire dates:** Random dates between January 2013 and December 2025
5. **Emergency contacts:** Generate a realistic name and `(425) 555-{4-digit}` phone (range 9001–9350)
6. **Room assignments:** Each employee gets a unique office room in their assigned building. Assign sequentially.
7. **IDs:** Sequential starting from 1

### JSON file structure

```json
{
  "buildings": [
    {
      "id": 1,
      "name": "Cascade Tower",
      "code": "A",
      "address": "156 NE 40th St",
      "city": "Redmond",
      "state": "WA",
      "zipCode": "98052",
      "floors": 4,
      "yearBuilt": 2015,
      "phone": "(425) 555-1001",
      "description": "Flagship engineering building...",
      "primaryDepartments": "Engineering"
    }
  ],
  "rooms": [
    {
      "id": 1,
      "buildingId": 1,
      "floor": 1,
      "roomNumber": "A-101",
      "type": "Office",
      "capacity": 1,
      "hasWindow": true,
      "notes": null,
      "assignedEmployeeId": 11
    }
  ],
  "employees": [
    {
      "id": 1,
      "firstName": "Sarah",
      "lastName": "Chen",
      "email": "sarah.chen@cascadeinnovations.com",
      "phone": "(425) 555-2001",
      "department": "Executive",
      "title": "CEO",
      "hireDate": "2012-06-15",
      "buildingId": 6,
      "roomId": 380,
      "emergencyContactName": "Robert Chen",
      "emergencyContactPhone": "(425) 555-9001"
    }
  ]
}
```

Make sure the JSON is well-formed and all cross-references (buildingId, roomId, assignedEmployeeId) are consistent.

---

## Step 3: Create the Office Data Service

Create `Services/OfficeDataService.cs`. Register as a **singleton** in `Program.cs`. Loads all data from `Data/seed-data.json` on construction and stores it in in-memory lists. All CRUD operations modify these lists.

```csharp
using System.Text.Json;
using RazorPages.Models;

namespace RazorPages.Services;

public class OfficeDataService
{
    private List<Building> _buildings = [];
    private List<Room> _rooms = [];
    private List<Employee> _employees = [];

    public OfficeDataService(IWebHostEnvironment env)
    {
        var path = Path.Combine(env.ContentRootPath, "Data", "seed-data.json");
        if (File.Exists(path))
        {
            var json = File.ReadAllText(path);
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var data = JsonSerializer.Deserialize<SeedData>(json, options);
            if (data is not null)
            {
                _buildings = data.Buildings;
                _rooms = data.Rooms;
                _employees = data.Employees;
            }
        }
    }

    // --- Buildings ---
    public IReadOnlyList<Building> GetAllBuildings() => _buildings;
    public Building? GetBuildingById(int id) => _buildings.FirstOrDefault(b => b.Id == id);
    public void UpdateBuilding(Building updated)
    {
        var index = _buildings.FindIndex(b => b.Id == updated.Id);
        if (index >= 0) _buildings[index] = updated;
    }

    // --- Rooms ---
    public IReadOnlyList<Room> GetAllRooms() => _rooms;
    public IReadOnlyList<Room> GetRoomsByBuilding(int buildingId) =>
        _rooms.Where(r => r.BuildingId == buildingId).ToList();
    public Room? GetRoomById(int id) => _rooms.FirstOrDefault(r => r.Id == id);
    public IReadOnlyList<Room> GetRoomsByFloor(int buildingId, int floor) =>
        _rooms.Where(r => r.BuildingId == buildingId && r.Floor == floor).ToList();
    public void UpdateRoom(Room updated)
    {
        var index = _rooms.FindIndex(r => r.Id == updated.Id);
        if (index >= 0) _rooms[index] = updated;
    }

    // --- Employees ---
    public IReadOnlyList<Employee> GetAllEmployees() => _employees;
    public Employee? GetEmployeeById(int id) => _employees.FirstOrDefault(e => e.Id == id);
    public IReadOnlyList<Employee> GetEmployeesByBuilding(int buildingId) =>
        _employees.Where(e => e.BuildingId == buildingId).ToList();
    public IReadOnlyList<Employee> GetEmployeesByDepartment(string department) =>
        _employees.Where(e => e.Department.Equals(department, StringComparison.OrdinalIgnoreCase)).ToList();
    public IReadOnlyList<string> GetDepartments() =>
        _employees.Select(e => e.Department).Distinct().OrderBy(d => d).ToList();
    public void UpdateEmployee(Employee updated)
    {
        var index = _employees.FindIndex(e => e.Id == updated.Id);
        if (index >= 0) _employees[index] = updated;
    }

    // --- Stats ---
    public int TotalBuildings => _buildings.Count;
    public int TotalRooms => _rooms.Count;
    public int TotalEmployees => _employees.Count;
    public int OccupiedOffices => _rooms.Count(r => r.Type == "Office" && r.AssignedEmployeeId.HasValue);
    public int AvailableOffices => _rooms.Count(r => r.Type == "Office" && !r.AssignedEmployeeId.HasValue);

    // --- Lookup helpers ---
    public string GetBuildingName(int buildingId) =>
        _buildings.FirstOrDefault(b => b.Id == buildingId)?.Name ?? "Unknown";
    public string GetRoomNumber(int roomId) =>
        _rooms.FirstOrDefault(r => r.Id == roomId)?.RoomNumber ?? "Unknown";
    public Employee? GetEmployeeByRoom(int roomId) =>
        _employees.FirstOrDefault(e => e.RoomId == roomId);

    private class SeedData
    {
        public List<Building> Buildings { get; set; } = [];
        public List<Room> Rooms { get; set; } = [];
        public List<Employee> Employees { get; set; } = [];
    }
}
```

---

## Step 4: Update Program.cs

Replace the contents of `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddSingleton<RazorPages.Services.OfficeDataService>();
builder.Services.AddRazorPages();

var app = builder.Build();

// Eagerly initialize the data service to load seed data at startup
app.Services.GetRequiredService<RazorPages.Services.OfficeDataService>();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();
app.MapRazorPages()
   .WithStaticAssets();

app.Run();
```

---

## Step 5: Update the Layout for Tailwind CSS

Replace `Pages/Shared/_Layout.cshtml`. Remove all Bootstrap references and use the Tailwind CDN. Include a professional navigation bar with links to Dashboard, Buildings, Rooms, and Employees. Include the reusable confirmation modal and its JavaScript at the bottom of the body.

```html
<!DOCTYPE html>
<html lang="en" class="h-full bg-gray-50">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@ViewData["Title"] - Cascade Innovations</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        cascade: {
                            50: '#eff6ff',
                            100: '#dbeafe',
                            200: '#bfdbfe',
                            300: '#93c5fd',
                            400: '#60a5fa',
                            500: '#3b82f6',
                            600: '#2563eb',
                            700: '#1d4ed8',
                            800: '#1e40af',
                            900: '#1e3a8a',
                        }
                    }
                }
            }
        }
    </script>
</head>
<body class="h-full">
    <div class="min-h-full">
        <!-- Navigation -->
        <nav class="bg-cascade-800 shadow-lg">
            <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                <div class="flex h-16 items-center justify-between">
                    <div class="flex items-center">
                        <a asp-page="/Index" class="flex items-center space-x-2">
                            <span class="text-2xl">🏢</span>
                            <span class="text-white text-xl font-bold">Cascade Innovations</span>
                        </a>
                        <div class="ml-10 flex items-baseline space-x-4">
                            <a asp-page="/Index" class="text-gray-300 hover:bg-cascade-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium">Dashboard</a>
                            <a asp-page="/Buildings/Index" class="text-gray-300 hover:bg-cascade-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium">Buildings</a>
                            <a asp-page="/Rooms/Index" class="text-gray-300 hover:bg-cascade-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium">Rooms</a>
                            <a asp-page="/Employees/Index" class="text-gray-300 hover:bg-cascade-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium">Employees</a>
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main content -->
        <main>
            <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
                @RenderBody()
            </div>
        </main>

        <!-- Footer -->
        <footer class="bg-white border-t border-gray-200 mt-12">
            <div class="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
                <p class="text-center text-sm text-gray-500">
                    &copy; 2026 Cascade Innovations — Office Management Demo
                </p>
            </div>
        </footer>
    </div>

    <!-- Confirmation Modal (reusable) -->
    <div id="confirmModal" class="relative z-50 hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="fixed inset-0 bg-gray-500/75 transition-opacity"></div>
        <div class="fixed inset-0 z-50 w-screen overflow-y-auto">
            <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                <div class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
                    <div class="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
                        <div class="sm:flex sm:items-start">
                            <div class="mx-auto flex size-12 shrink-0 items-center justify-center rounded-full bg-amber-100 sm:mx-0 sm:size-10">
                                <span class="text-xl">⚠️</span>
                            </div>
                            <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                                <h3 class="text-base font-semibold text-gray-900" id="modal-title">Confirm Changes</h3>
                                <div class="mt-2">
                                    <p class="text-sm text-gray-500" id="modal-message">Are you sure you want to save these changes?</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
                        <button type="button" id="confirmBtn" class="inline-flex w-full justify-center rounded-md bg-cascade-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-cascade-500 sm:ml-3 sm:w-auto">
                            Confirm
                        </button>
                        <button type="button" id="cancelBtn" class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto">
                            Cancel
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Confirmation modal logic
        function showConfirmModal(message, onConfirm) {
            const modal = document.getElementById('confirmModal');
            const messageEl = document.getElementById('modal-message');
            const confirmBtn = document.getElementById('confirmBtn');
            const cancelBtn = document.getElementById('cancelBtn');

            messageEl.textContent = message;
            modal.classList.remove('hidden');

            const cleanup = () => {
                modal.classList.add('hidden');
                confirmBtn.removeEventListener('click', handleConfirm);
                cancelBtn.removeEventListener('click', handleCancel);
            };

            const handleConfirm = () => { cleanup(); onConfirm(); };
            const handleCancel = () => { cleanup(); };

            confirmBtn.addEventListener('click', handleConfirm);
            cancelBtn.addEventListener('click', handleCancel);
        }

        // Auto-attach to forms with data-confirm attribute
        document.addEventListener('DOMContentLoaded', () => {
            document.querySelectorAll('form[data-confirm]').forEach(form => {
                form.addEventListener('submit', (e) => {
                    e.preventDefault();
                    showConfirmModal(form.dataset.confirm, () => {
                        form.removeAttribute('data-confirm');
                        form.submit();
                    });
                });
            });
        });
    </script>

    @await RenderSectionAsync("Scripts", required: false)
</body>
</html>
```

Also:
- **Delete** `Pages/Shared/_Layout.cshtml.css` (no longer needed — Tailwind replaces Bootstrap)
- **Clear** `wwwroot/css/site.css` to an empty file or remove it (Tailwind CDN handles all styling)

---

## Step 6: Create the Dashboard (Home Page)

Replace `Pages/Index.cshtml` and `Pages/Index.cshtml.cs`.

### Index.cshtml.cs

```csharp
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
```

### Index.cshtml

```html
@page
@model IndexModel
@{
    ViewData["Title"] = "Dashboard";
}

<div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-900">🏢 Office Management Dashboard</h1>
    <p class="mt-2 text-gray-600">Cascade Innovations — Redmond, WA Campus Overview</p>
</div>

<!-- Stats Cards -->
<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-5 mb-8">
    <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="p-5">
            <div class="flex items-center">
                <div class="shrink-0 text-3xl">🏗️</div>
                <div class="ml-4">
                    <p class="text-sm font-medium text-gray-500 truncate">Buildings</p>
                    <p class="text-2xl font-semibold text-gray-900">@Model.TotalBuildings</p>
                </div>
            </div>
        </div>
    </div>
    <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="p-5">
            <div class="flex items-center">
                <div class="shrink-0 text-3xl">👥</div>
                <div class="ml-4">
                    <p class="text-sm font-medium text-gray-500 truncate">Employees</p>
                    <p class="text-2xl font-semibold text-gray-900">@Model.TotalEmployees</p>
                </div>
            </div>
        </div>
    </div>
    <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="p-5">
            <div class="flex items-center">
                <div class="shrink-0 text-3xl">🚪</div>
                <div class="ml-4">
                    <p class="text-sm font-medium text-gray-500 truncate">Total Rooms</p>
                    <p class="text-2xl font-semibold text-gray-900">@Model.TotalRooms</p>
                </div>
            </div>
        </div>
    </div>
    <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="p-5">
            <div class="flex items-center">
                <div class="shrink-0 text-3xl">✅</div>
                <div class="ml-4">
                    <p class="text-sm font-medium text-gray-500 truncate">Occupied</p>
                    <p class="text-2xl font-semibold text-gray-900">@Model.OccupiedOffices</p>
                </div>
            </div>
        </div>
    </div>
    <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="p-5">
            <div class="flex items-center">
                <div class="shrink-0 text-3xl">📭</div>
                <div class="ml-4">
                    <p class="text-sm font-medium text-gray-500 truncate">Available</p>
                    <p class="text-2xl font-semibold text-gray-900">@Model.AvailableOffices</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Buildings Summary -->
<h2 class="text-xl font-semibold text-gray-900 mb-4">Campus Buildings</h2>
<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
    @foreach (var building in Model.Buildings)
    {
        <a asp-page="/Buildings/Details" asp-route-id="@building.Id"
           class="block bg-white shadow rounded-lg hover:shadow-md transition-shadow">
            <div class="p-6">
                <div class="flex items-center justify-between mb-2">
                    <h3 class="text-lg font-semibold text-cascade-700">@building.Name</h3>
                    <span class="inline-flex items-center rounded-full bg-cascade-100 px-2.5 py-0.5 text-xs font-medium text-cascade-800">
                        @building.Code
                    </span>
                </div>
                <p class="text-sm text-gray-500 mb-3">@building.Address, @building.City, @building.State</p>
                <div class="flex justify-between text-sm">
                    <span class="text-gray-600">👥 @Model.EmployeeCountByBuilding[building.Id] employees</span>
                    <span class="text-gray-600">🏢 @building.Floors floors</span>
                </div>
            </div>
        </a>
    }
</div>
```

---

## Step 7: Create Buildings Pages

Create the `Pages/Buildings/` folder with three pages: `Index`, `Details`, and `Edit`.

### Pages/Buildings/Index.cshtml.cs

```csharp
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
```

### Pages/Buildings/Index.cshtml

Display all buildings in a responsive Tailwind table with columns: Code, Name, Address, Floors, Year Built, Employees, Rooms, and an action column with "View Details" link. Include page header: `🏗️ Office Buildings`. Each row's "View Details" links to the `Details` page.

### Pages/Buildings/Details.cshtml.cs

```csharp
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
```

### Pages/Buildings/Details.cshtml

Display building info in a card at the top (name, code, address, city/state/zip, phone, year built, description, primary departments). Below, show a section for each floor with rooms in a table (Room Number, Type, Capacity, Window, Assigned Employee — linked to `/Employees/Details`). Below that, show a table of all employees in the building (Name — linked, Department, Title, Room). Include "✏️ Edit Building" button linking to Edit page and "← Back to Buildings" link.

### Pages/Buildings/Edit.cshtml.cs

```csharp
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
```

### Pages/Buildings/Edit.cshtml

Form to edit: Name, Address, City, State, ZipCode, Phone, Description, PrimaryDepartments. Id, Code, Floors, and YearBuilt are displayed as read-only info (not editable). Use `<form method="post" data-confirm="Are you sure you want to update this building's information?">`. Style with Tailwind form classes. Include "💾 Save Changes" submit button and "Cancel" link back to Details.

---

## Step 8: Create Rooms Pages

Create the `Pages/Rooms/` folder with three pages: `Index`, `Details`, and `Edit`.

### Pages/Rooms/Index.cshtml.cs

```csharp
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
```

### Pages/Rooms/Index.cshtml

Page header: `🚪 Rooms`. Filter bar with three dropdowns: Building (all buildings), Floor (1-4), Room Type (Office, Conference Room, Break Room, etc.). Display results in a table: Room Number, Building, Floor, Type (color-coded badges: Office=blue, Conference=green, Break Room=amber, others=gray), Capacity, Window (✅/—), Assigned Employee (linked), and "View" action. Show result count (e.g., "Showing 396 rooms").

### Pages/Rooms/Details.cshtml.cs

```csharp
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
```

### Pages/Rooms/Details.cshtml

Show room info card: Room Number, Building (linked), Floor, Type (badge), Capacity, Window status, Notes. If occupied, show assigned employee info with link to employee detail. Include "✏️ Edit Room" button and "← Back to Rooms" link.

### Pages/Rooms/Edit.cshtml.cs

```csharp
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
```

### Pages/Rooms/Edit.cshtml

Form to edit: Type (dropdown: Office, Conference Room, Break Room, Server Room, etc.), Capacity, HasWindow (checkbox), Notes (textarea), AssignedEmployeeId (dropdown of available employees + "Unoccupied" option). Room Number, Building, and Floor are displayed read-only. Use `data-confirm="Are you sure you want to update this room's details?"`. Include "💾 Save Changes" and "Cancel" buttons.

---

## Step 9: Create Employees Pages

Create the `Pages/Employees/` folder with three pages: `Index`, `Details`, and `Edit`.

### Pages/Employees/Index.cshtml.cs

```csharp
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
```

### Pages/Employees/Index.cshtml

Page header: `👥 Employees` with a count badge (e.g., "350 employees"). Search bar (searches name and email) and filter dropdowns (Department, Building). Display results in a Tailwind table with zebra striping: Name (linked to Details), Department (badge), Title, Building, Room, Email. Show result count below filters.

### Pages/Employees/Details.cshtml.cs

```csharp
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
```

### Pages/Employees/Details.cshtml

Display a profile card with two columns:
- **Left column:** Full name (large), title, department (badge), email (mailto link), phone, hire date (formatted nicely)
- **Right column:** Building (linked to Building Details), Room number (linked to Room Details), emergency contact name and phone

Include "✏️ Edit Employee" button and "← Back to Employees" link.

### Pages/Employees/Edit.cshtml.cs

```csharp
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

    // JSON for client-side building→room filtering
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

        // Build a JSON map of buildingId → rooms for client-side filtering
        var roomsByBuilding = AllOfficeRooms
            .GroupBy(r => r.BuildingId)
            .ToDictionary(
                g => g.Key.ToString(),
                g => g.Select(r => new { id = r.Id, roomNumber = r.RoomNumber }).ToList()
            );
        RoomsByBuildingJson = JsonSerializer.Serialize(roomsByBuilding);
    }
}
```

### Pages/Employees/Edit.cshtml

Form to edit all employee fields:
- **Personal:** FirstName, LastName, Email, Phone
- **Work:** Department (dropdown from existing departments), Title (text input), HireDate (date input)
- **Location:** BuildingId (dropdown), RoomId (dropdown — dynamically filtered by building selection using JavaScript)
- **Emergency Contact:** EmergencyContactName, EmergencyContactPhone

Include hidden field for Id. Use `data-confirm="Are you sure you want to update this employee's information?"`.

**JavaScript for dynamic room filtering:** When the building dropdown changes, filter the room dropdown to show only rooms in the selected building. Use the `RoomsByBuildingJson` data passed from the page model. Preserve the currently selected room if it belongs to the selected building.

```html
@section Scripts {
    <script>
        const roomsByBuilding = @Html.Raw(Model.RoomsByBuildingJson);
        const buildingSelect = document.getElementById('buildingId');
        const roomSelect = document.getElementById('roomId');
        const currentRoomId = @Model.Employee.RoomId;

        buildingSelect.addEventListener('change', () => {
            const buildingId = buildingSelect.value;
            const rooms = roomsByBuilding[buildingId] || [];
            roomSelect.innerHTML = '';
            rooms.forEach(room => {
                const option = document.createElement('option');
                option.value = room.id;
                option.textContent = room.roomNumber;
                if (room.id === currentRoomId) option.selected = true;
                roomSelect.appendChild(option);
            });
        });
    </script>
}
```

Include "💾 Save Changes" and "Cancel" buttons.

---

## Step 10: Remove Unused Files

- **Delete** `Pages/Privacy.cshtml` and `Pages/Privacy.cshtml.cs` (not needed for this app)
- **Delete** `Pages/Shared/_Layout.cshtml.css` (replaced by Tailwind)
- **Clear** `wwwroot/css/site.css` to empty (Tailwind CDN handles all styling)

---

## Step 11: Update _ViewImports.cshtml

Ensure `Pages/_ViewImports.cshtml` includes necessary usings:

```html
@using RazorPages
@using RazorPages.Models
@using RazorPages.Services
@namespace RazorPages.Pages
@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
```

---

## Step 12: Build and Verify

```shell
cd src/RazorPages/RazorPages
dotnet build
dotnet run
```

### Verification checklist

1. ✅ **Dashboard** loads at root URL showing stats: 6 buildings, 350 employees, ~396 rooms, occupied/available counts
2. ✅ **Buildings list** (`/Buildings`) shows all 6 buildings in a table with employee and room counts
3. ✅ **Building detail** (`/Buildings/Details?id=1`) shows building info card, rooms grouped by floor, and employee list
4. ✅ **Building edit** (`/Buildings/Edit?id=1`) allows editing building details; confirmation modal appears before save
5. ✅ **Rooms list** (`/Rooms`) shows all rooms with building, floor, and type filter dropdowns working
6. ✅ **Room detail** (`/Rooms/Details?id=1`) shows room info and assigned employee with links
7. ✅ **Room edit** (`/Rooms/Edit?id=1`) allows editing room details; confirmation modal appears before save
8. ✅ **Employees list** (`/Employees`) shows all 350 employees; search by name/email works; department and building filters work
9. ✅ **Employee detail** (`/Employees/Details?id=1`) shows full profile with linked building and room
10. ✅ **Employee edit** (`/Employees/Edit?id=1`) allows editing all fields; building dropdown dynamically filters room dropdown; confirmation modal appears before save
11. ✅ **Navigation** — all navbar links work; back/forward navigation is consistent
12. ✅ **Tailwind CSS** — styling renders properly via CDN; no Bootstrap remnants visible
13. ✅ **Confirmation modals** — custom Tailwind modal appears before saving on all three edit pages
14. ✅ **In-memory persistence** — edits made via the UI persist while the app is running (verified by editing, navigating away, and returning)
15. ✅ **Seed data loads** — all 350 employees, all 6 buildings, and all ~396 rooms load correctly from `Data/seed-data.json` at startup
