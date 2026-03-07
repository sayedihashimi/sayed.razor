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
