namespace RazorPages.Services;

using RazorPages.Models;

public class ProductService
{
    private static readonly List<Product> _products = new()
    {
        new Product
        {
            Id = 1,
            Name = "Trail Runner Pro",
            Category = "Footwear",
            Price = 129.99m,
            Description = "Lightweight trail running shoes with Vibram outsole and breathable mesh upper. Built for speed on technical terrain.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=Trail+Runner+Pro"
        },
        new Product
        {
            Id = 2,
            Name = "Summit Hiking Boot",
            Category = "Footwear",
            Price = 189.99m,
            Description = "Full-grain leather hiking boot with Gore-Tex waterproof membrane. Ankle support and cushioned midsole for all-day comfort on rugged trails.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=Summit+Hiking+Boot"
        },
        new Product
        {
            Id = 3,
            Name = "DayTripper 24L Pack",
            Category = "Backpacks",
            Price = 79.99m,
            Description = "Compact daypack with hydration sleeve, hip belt pockets, and rain cover. Perfect for day hikes and short adventures.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=DayTripper+24L+Pack"
        },
        new Product
        {
            Id = 4,
            Name = "Ridgeline 65L Expedition Pack",
            Category = "Backpacks",
            Price = 249.99m,
            Description = "Top-loading expedition backpack with adjustable torso length, load lifters, and multiple access points. Built for multi-day backcountry trips.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=Ridgeline+65L+Expedition+Pack"
        },
        new Product
        {
            Id = 5,
            Name = "UltraLight 2P Tent",
            Category = "Shelter",
            Price = 349.99m,
            Description = "Freestanding two-person tent weighing just 3.2 lbs. Double-wall construction with full mesh inner for ventilation. Sets up in under 3 minutes.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=UltraLight+2P+Tent"
        },
        new Product
        {
            Id = 6,
            Name = "BaseCamp 4P Tent",
            Category = "Shelter",
            Price = 449.99m,
            Description = "Spacious four-person tent with two vestibules and a peak height of 5 feet. Four-season rated with reinforced pole structure for wind resistance.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=BaseCamp+4P+Tent"
        },
        new Product
        {
            Id = 7,
            Name = "ClearFlow Water Bottle 32oz",
            Category = "Hydration",
            Price = 24.99m,
            Description = "BPA-free Tritan water bottle with built-in filter and leak-proof flip cap. Removes 99.9% of waterborne bacteria.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=ClearFlow+Water+Bottle+32oz"
        },
        new Product
        {
            Id = 8,
            Name = "HydraStream 2L Bladder",
            Category = "Hydration",
            Price = 34.99m,
            Description = "Insulated hydration bladder with quick-disconnect hose and wide-mouth opening for easy filling and cleaning.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=HydraStream+2L+Bladder"
        },
        new Product
        {
            Id = 9,
            Name = "StormShield Rain Jacket",
            Category = "Clothing",
            Price = 159.99m,
            Description = "Three-layer waterproof breathable jacket with sealed seams, adjustable hood, and pit zips. Packs into its own chest pocket.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=StormShield+Rain+Jacket"
        },
        new Product
        {
            Id = 10,
            Name = "MerinoBase 200 Long Sleeve",
            Category = "Clothing",
            Price = 74.99m,
            Description = "100% merino wool base layer with flatlock seams. Naturally odor-resistant and temperature-regulating for all-season comfort.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=MerinoBase+200+Long+Sleeve"
        },
        new Product
        {
            Id = 11,
            Name = "TrailBeam 600 Headlamp",
            Category = "Lighting",
            Price = 44.99m,
            Description = "600-lumen rechargeable headlamp with red night-vision mode. IPX7 waterproof with 40-hour battery life on low.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=TrailBeam+600+Headlamp"
        },
        new Product
        {
            Id = 12,
            Name = "CampGlow Lantern",
            Category = "Lighting",
            Price = 29.99m,
            Description = "Collapsible LED lantern with USB charging and built-in power bank. 300 lumens with warm and cool light modes.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=CampGlow+Lantern"
        },
        new Product
        {
            Id = 13,
            Name = "Carbon Trek Trekking Poles",
            Category = "Accessories",
            Price = 99.99m,
            Description = "Ultralight carbon fiber trekking poles with cork grips and quick-lock adjustment. Pair weighs just 14 oz.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=Carbon+Trek+Trekking+Poles"
        },
        new Product
        {
            Id = 14,
            Name = "TrailNav Compass",
            Category = "Accessories",
            Price = 19.99m,
            Description = "Liquid-filled orienteering compass with declination adjustment, magnifying lens, and luminous bezel. Reliable navigation when GPS fails.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=TrailNav+Compass"
        },
        new Product
        {
            Id = 15,
            Name = "WildernessReady First Aid Kit",
            Category = "Accessories",
            Price = 39.99m,
            Description = "Comprehensive 120-piece first aid kit in a water-resistant case. Includes blister care, trauma supplies, and a wilderness first aid guide.",
            ImageUrl = "https://placehold.co/400x300/2d5016/white?text=WildernessReady+First+Aid+Kit"
        }
    };

    public IReadOnlyList<Product> GetAll() => _products;

    public Product? GetById(int id) => _products.FirstOrDefault(p => p.Id == id);

    public IReadOnlyList<Product> GetByCategory(string category) =>
        _products.Where(p => p.Category.Equals(category, StringComparison.OrdinalIgnoreCase)).ToList();

    public IReadOnlyList<string> GetCategories() =>
        _products.Select(p => p.Category).Distinct().OrderBy(c => c).ToList();
}
