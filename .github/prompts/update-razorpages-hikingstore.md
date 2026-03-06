# Update RazorPages App to HikeR Hiking Supply Store

Transform the default ASP.NET Core Razor Pages app at `src/RazorPages/RazorPages/` into **HikeR** — a fictitious hiking supply store. This is a demo app, so all data is stored in memory. No database, no Entity Framework.

- **Project path:** `src/RazorPages/RazorPages/`
- **Data storage:** In-memory only (static list)
- **Styling:** Bootstrap (already included) + custom outdoor-themed CSS
- **Images:** Placeholder service URLs (no local image files)

---

## Step 1: Create the Product Model

Create `Models/Product.cs`:

```csharp
namespace RazorPages.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
}
```

---

## Step 2: Create the In-Memory Product Service

Create `Services/ProductService.cs` with a hardcoded list of **at least 15 products** across multiple categories. Register it as a singleton in `Program.cs`.

### Categories to include

Use these categories (at minimum): **Footwear**, **Backpacks**, **Shelter**, **Hydration**, **Clothing**, **Lighting**, **Accessories**.

### Product catalog

Seed the service with realistic hiking gear. Here are the products to include (at minimum):

| # | Name | Category | Price | Description |
|---|------|----------|-------|-------------|
| 1 | Trail Runner Pro | Footwear | $129.99 | Lightweight trail running shoes with Vibram outsole and breathable mesh upper. Built for speed on technical terrain. |
| 2 | Summit Hiking Boot | Footwear | $189.99 | Full-grain leather hiking boot with Gore-Tex waterproof membrane. Ankle support and cushioned midsole for all-day comfort on rugged trails. |
| 3 | DayTripper 24L Pack | Backpacks | $79.99 | Compact daypack with hydration sleeve, hip belt pockets, and rain cover. Perfect for day hikes and short adventures. |
| 4 | Ridgeline 65L Expedition Pack | Backpacks | $249.99 | Top-loading expedition backpack with adjustable torso length, load lifters, and multiple access points. Built for multi-day backcountry trips. |
| 5 | UltraLight 2P Tent | Shelter | $349.99 | Freestanding two-person tent weighing just 3.2 lbs. Double-wall construction with full mesh inner for ventilation. Sets up in under 3 minutes. |
| 6 | BaseCamp 4P Tent | Shelter | $449.99 | Spacious four-person tent with two vestibules and a peak height of 5 feet. Four-season rated with reinforced pole structure for wind resistance. |
| 7 | ClearFlow Water Bottle 32oz | Hydration | $24.99 | BPA-free Tritan water bottle with built-in filter and leak-proof flip cap. Removes 99.9% of waterborne bacteria. |
| 8 | HydraStream 2L Bladder | Hydration | $34.99 | Insulated hydration bladder with quick-disconnect hose and wide-mouth opening for easy filling and cleaning. |
| 9 | StormShield Rain Jacket | Clothing | $159.99 | Three-layer waterproof breathable jacket with sealed seams, adjustable hood, and pit zips. Packs into its own chest pocket. |
| 10 | MerinoBase 200 Long Sleeve | Clothing | $74.99 | 100% merino wool base layer with flatlock seams. Naturally odor-resistant and temperature-regulating for all-season comfort. |
| 11 | TrailBeam 600 Headlamp | Lighting | $44.99 | 600-lumen rechargeable headlamp with red night-vision mode. IPX7 waterproof with 40-hour battery life on low. |
| 12 | CampGlow Lantern | Lighting | $29.99 | Collapsible LED lantern with USB charging and built-in power bank. 300 lumens with warm and cool light modes. |
| 13 | Carbon Trek Trekking Poles | Accessories | $99.99 | Ultralight carbon fiber trekking poles with cork grips and quick-lock adjustment. Pair weighs just 14 oz. |
| 14 | TrailNav Compass | Accessories | $19.99 | Liquid-filled orienteering compass with declination adjustment, magnifying lens, and luminous bezel. Reliable navigation when GPS fails. |
| 15 | WildernessReady First Aid Kit | Accessories | $39.99 | Comprehensive 120-piece first aid kit in a water-resistant case. Includes blister care, trauma supplies, and a wilderness first aid guide. |

### Service implementation

```csharp
namespace RazorPages.Services;

using RazorPages.Models;

public class ProductService
{
    private static readonly List<Product> _products = new()
    {
        // Populate with ALL products from the table above
    };

    public IReadOnlyList<Product> GetAll() => _products;

    public Product? GetById(int id) => _products.FirstOrDefault(p => p.Id == id);

    public IReadOnlyList<Product> GetByCategory(string category) =>
        _products.Where(p => p.Category.Equals(category, StringComparison.OrdinalIgnoreCase)).ToList();

    public IReadOnlyList<string> GetCategories() =>
        _products.Select(p => p.Category).Distinct().OrderBy(c => c).ToList();
}
```

### Image URLs

For each product, use a placeholder URL in this format:

```
https://placehold.co/400x300/2d5016/white?text={ProductName}
```

Replace `{ProductName}` with a URL-encoded version of the product name (replace spaces with `+`). The green background (`2d5016`) fits the outdoor theme.

---

## Step 3: Register the Service in Program.cs

Add this line before `var app = builder.Build();`:

```csharp
builder.Services.AddSingleton<RazorPages.Services.ProductService>();
```

---

## Step 4: Update the Home Page (Product Catalog)

Replace the content of `Pages/Index.cshtml` and `Pages/Index.cshtml.cs` to display the product catalog.

### Index.cshtml.cs

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages;

public class IndexModel : PageModel
{
    private readonly ProductService _productService;

    public IndexModel(ProductService productService)
    {
        _productService = productService;
    }

    public IReadOnlyList<Product> Products { get; set; } = [];
    public IReadOnlyList<string> Categories { get; set; } = [];

    [BindProperty(SupportsGet = true)]
    public string? Category { get; set; }

    public void OnGet()
    {
        Categories = _productService.GetCategories();
        Products = string.IsNullOrEmpty(Category)
            ? _productService.GetAll()
            : _productService.GetByCategory(Category);
    }
}
```

### Index.cshtml

```html
@page
@model IndexModel
@{
    ViewData["Title"] = "Shop Hiking Gear";
}

<div class="container">
    <div class="text-center mb-4">
        <h1 class="display-5 fw-bold text-success-emphasis">⛰️ HikeR Gear Shop</h1>
        <p class="lead text-muted">Everything you need for your next adventure</p>
    </div>

    <!-- Category Filter -->
    <div class="mb-4 text-center">
        <a asp-page="/Index" class="btn @(Model.Category == null ? "btn-success" : "btn-outline-success") btn-sm me-1 mb-1">All</a>
        @foreach (var cat in Model.Categories)
        {
            <a asp-page="/Index" asp-route-category="@cat"
               class="btn @(Model.Category == cat ? "btn-success" : "btn-outline-success") btn-sm me-1 mb-1">@cat</a>
        }
    </div>

    <!-- Product Grid -->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
        @foreach (var product in Model.Products)
        {
            <div class="col">
                <div class="card h-100 product-card shadow-sm">
                    <img src="@product.ImageUrl" class="card-img-top" alt="@product.Name" loading="lazy" />
                    <div class="card-body d-flex flex-column">
                        <span class="badge bg-success-subtle text-success-emphasis mb-2 align-self-start">@product.Category</span>
                        <h5 class="card-title">@product.Name</h5>
                        <p class="card-text text-muted small flex-grow-1">@product.Description</p>
                        <div class="d-flex justify-content-between align-items-center mt-2">
                            <span class="fs-5 fw-bold text-success">@product.Price.ToString("C")</span>
                            <a asp-page="/ProductDetail" asp-route-id="@product.Id" class="btn btn-outline-success btn-sm">View Details</a>
                        </div>
                    </div>
                </div>
            </div>
        }
    </div>
</div>
```

---

## Step 5: Create the Product Detail Page

### Pages/ProductDetail.cshtml.cs

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages;

public class ProductDetailModel : PageModel
{
    private readonly ProductService _productService;

    public ProductDetailModel(ProductService productService)
    {
        _productService = productService;
    }

    public Product? Product { get; set; }

    public IActionResult OnGet(int id)
    {
        Product = _productService.GetById(id);
        if (Product is null)
        {
            return NotFound();
        }
        return Page();
    }
}
```

### Pages/ProductDetail.cshtml

```html
@page "{id:int}"
@model ProductDetailModel
@{
    ViewData["Title"] = Model.Product?.Name ?? "Product Not Found";
}

<div class="container py-4">
    @if (Model.Product is not null)
    {
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a asp-page="/Index">Shop</a></li>
                <li class="breadcrumb-item">
                    <a asp-page="/Index" asp-route-category="@Model.Product.Category">@Model.Product.Category</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">@Model.Product.Name</li>
            </ol>
        </nav>

        <div class="row g-4">
            <div class="col-md-6">
                <img src="@Model.Product.ImageUrl" class="img-fluid rounded shadow" alt="@Model.Product.Name" />
            </div>
            <div class="col-md-6">
                <span class="badge bg-success-subtle text-success-emphasis mb-2">@Model.Product.Category</span>
                <h1 class="fw-bold">@Model.Product.Name</h1>
                <p class="fs-3 fw-bold text-success my-3">@Model.Product.Price.ToString("C")</p>
                <p class="lead">@Model.Product.Description</p>
                <a asp-page="/Index" class="btn btn-outline-success mt-3">← Back to Shop</a>
            </div>
        </div>
    }
</div>
```

---

## Step 6: Update the Layout for HikeR Branding

Update `Pages/Shared/_Layout.cshtml`:

1. Change the page `<title>` from `RazorPages` to `HikeR`:
   ```html
   <title>@ViewData["Title"] - HikeR</title>
   ```

2. Change the navbar brand:
   ```html
   <a class="navbar-brand fw-bold" asp-area="" asp-page="/Index">🥾 HikeR</a>
   ```

3. Update the nav links — rename "Home" to "Shop" and keep "Privacy":
   ```html
   <li class="nav-item">
       <a class="nav-link text-dark" asp-area="" asp-page="/Index">Shop</a>
   </li>
   <li class="nav-item">
       <a class="nav-link text-dark" asp-area="" asp-page="/Privacy">Privacy</a>
   </li>
   ```

4. Update the footer:
   ```html
   <footer class="border-top footer text-muted">
       <div class="container">
           &copy; 2026 - 🥾 HikeR — Your Trail Starts Here - <a asp-area="" asp-page="/Privacy">Privacy</a>
       </div>
   </footer>
   ```

5. Change the navbar background for an outdoor feel:
   ```html
   <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-dark bg-success border-bottom box-shadow mb-3">
   ```
   When using `navbar-dark`, change the nav link classes from `text-dark` to `text-white`.

---

## Step 7: Update the Privacy Page

Update `Pages/Privacy.cshtml` with HikeR-branded content:

```html
@page
@model PrivacyModel
@{
    ViewData["Title"] = "Privacy Policy";
}
<h1>@ViewData["Title"]</h1>

<p>At HikeR, we respect your privacy on and off the trail. This demo application does not collect, store, or transmit any personal data. All product information is stored in memory and resets when the application restarts.</p>
```

---

## Step 8: Update CSS for Outdoor Theme

Add the following styles to `wwwroot/css/site.css`:

```css
/* HikeR Product Cards */
.product-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    border: none;
    border-radius: 0.75rem;
    overflow: hidden;
}

.product-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.15) !important;
}

.product-card .card-img-top {
    height: 200px;
    object-fit: cover;
    background-color: #2d5016;
}
```

---

## Verification

After making all changes, verify the app builds and runs:

```shell
cd src/RazorPages
dotnet build RazorPages.slnx
dotnet run --project RazorPages
```

Then open the browser and verify:

1. **Home page** shows a product grid with 15+ hiking products, category filter buttons, and the HikeR branding
2. **Clicking a product** navigates to the detail page with full product info and breadcrumb navigation
3. **Category filters** correctly filter the product list
4. **Navbar** shows "🥾 HikeR" brand with green background
5. **Footer** shows "HikeR — Your Trail Starts Here"
6. **Privacy page** shows HikeR-branded privacy text
