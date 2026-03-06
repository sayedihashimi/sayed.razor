# Update RazorPages App to HikeR Hiking Supply Store

Transform the default ASP.NET Core Razor Pages app at `src/RazorPages/RazorPages/` into **HikeR** — a fictitious hiking supply store. This is a demo app, so all data is stored in memory. No database, no Entity Framework.

- **Project path:** `src/RazorPages/RazorPages/`
- **Data storage:** In-memory only (static list + session-based shopping cart)
- **Styling:** Bootstrap (already included) + custom outdoor-themed CSS
- **Images:** Placeholder service URLs (no local image files)
- **Shopping cart:** Session-based, persists across pages during a user's visit
- **Checkout:** Collects shipping and payment info; no real validation on payment fields (demo only)

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

## Step 2: Create the Cart Item Model

Create `Models/CartItem.cs`:

```csharp
namespace RazorPages.Models;

public class CartItem
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Quantity { get; set; }
    public string ImageUrl { get; set; } = string.Empty;

    public decimal Subtotal => Price * Quantity;
}
```

---

## Step 3: Create the Checkout Info Model

Create `Models/CheckoutInfo.cs`:

```csharp
namespace RazorPages.Models;

public class CheckoutInfo
{
    // Shipping
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string State { get; set; } = string.Empty;
    public string ZipCode { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;

    // Payment
    public string CardNumber { get; set; } = string.Empty;
    public string CardholderName { get; set; } = string.Empty;
    public string ExpirationDate { get; set; } = string.Empty;
    public string Cvv { get; set; } = string.Empty;
}
```

---

## Step 4: Create the In-Memory Product Service

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

## Step 5: Create the Cart Service

Create `Services/CartService.cs`. This service stores the shopping cart in the ASP.NET Core session as serialized JSON.

```csharp
using System.Text.Json;
using RazorPages.Models;

namespace RazorPages.Services;

public class CartService
{
    private const string CartSessionKey = "HikeR_Cart";
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CartService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private ISession Session => _httpContextAccessor.HttpContext!.Session;

    public List<CartItem> GetItems()
    {
        var json = Session.GetString(CartSessionKey);
        if (string.IsNullOrEmpty(json))
        {
            return [];
        }
        return JsonSerializer.Deserialize<List<CartItem>>(json) ?? [];
    }

    public void AddItem(Product product, int quantity = 1)
    {
        var items = GetItems();
        var existing = items.FirstOrDefault(i => i.ProductId == product.Id);
        if (existing is not null)
        {
            existing.Quantity += quantity;
        }
        else
        {
            items.Add(new CartItem
            {
                ProductId = product.Id,
                ProductName = product.Name,
                Price = product.Price,
                Quantity = quantity,
                ImageUrl = product.ImageUrl
            });
        }
        SaveItems(items);
    }

    public void RemoveItem(int productId)
    {
        var items = GetItems();
        items.RemoveAll(i => i.ProductId == productId);
        SaveItems(items);
    }

    public void UpdateQuantity(int productId, int quantity)
    {
        var items = GetItems();
        var item = items.FirstOrDefault(i => i.ProductId == productId);
        if (item is not null)
        {
            if (quantity <= 0)
            {
                items.Remove(item);
            }
            else
            {
                item.Quantity = quantity;
            }
        }
        SaveItems(items);
    }

    public void Clear()
    {
        Session.Remove(CartSessionKey);
    }

    public int GetItemCount()
    {
        return GetItems().Sum(i => i.Quantity);
    }

    public decimal GetTotal()
    {
        return GetItems().Sum(i => i.Subtotal);
    }

    private void SaveItems(List<CartItem> items)
    {
        var json = JsonSerializer.Serialize(items);
        Session.SetString(CartSessionKey, json);
    }
}
```

---

## Step 6: Register Services and Session in Program.cs

Replace the service registration and middleware sections of `Program.cs`:

```csharp
// Add services to the container.
builder.Services.AddSingleton<RazorPages.Services.ProductService>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<RazorPages.Services.CartService>();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});
builder.Services.AddRazorPages();
```

Also add `app.UseSession();` to the middleware pipeline **before** `app.UseAuthorization();`:

```csharp
app.UseRouting();

app.UseSession();

app.UseAuthorization();
```

---

## Step 7: Update the Home Page (Product Catalog)

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
    private readonly CartService _cartService;

    public IndexModel(ProductService productService, CartService cartService)
    {
        _productService = productService;
        _cartService = cartService;
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

    public IActionResult OnPostAddToCart(int productId, string? category)
    {
        var product = _productService.GetById(productId);
        if (product is not null)
        {
            _cartService.AddItem(product);
        }
        return RedirectToPage("/Index", new { category });
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
                            <div class="btn-group btn-group-sm">
                                <a asp-page="/ProductDetail" asp-route-id="@product.Id" class="btn btn-outline-success">Details</a>
                                <form method="post" asp-page-handler="AddToCart" class="d-inline">
                                    <input type="hidden" name="productId" value="@product.Id" />
                                    <input type="hidden" name="category" value="@Model.Category" />
                                    <button type="submit" class="btn btn-success">🛒 Add</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        }
    </div>
</div>
```

---

## Step 8: Create the Product Detail Page

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
    private readonly CartService _cartService;

    public ProductDetailModel(ProductService productService, CartService cartService)
    {
        _productService = productService;
        _cartService = cartService;
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

    public IActionResult OnPostAddToCart(int id)
    {
        var product = _productService.GetById(id);
        if (product is not null)
        {
            _cartService.AddItem(product);
        }
        return RedirectToPage("/Cart");
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
                <form method="post" asp-page-handler="AddToCart" class="mt-3">
                    <input type="hidden" name="id" value="@Model.Product.Id" />
                    <button type="submit" class="btn btn-success btn-lg">🛒 Add to Cart</button>
                </form>
                <a asp-page="/Index" class="btn btn-outline-success mt-2">← Back to Shop</a>
            </div>
        </div>
    }
</div>
```

---

## Step 9: Create the Shopping Cart Page

### Pages/Cart.cshtml.cs

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages;

public class CartModel : PageModel
{
    private readonly CartService _cartService;

    public CartModel(CartService cartService)
    {
        _cartService = cartService;
    }

    public List<CartItem> Items { get; set; } = [];
    public decimal Total { get; set; }

    public void OnGet()
    {
        Items = _cartService.GetItems();
        Total = _cartService.GetTotal();
    }

    public IActionResult OnPostUpdateQuantity(int productId, int quantity)
    {
        _cartService.UpdateQuantity(productId, quantity);
        return RedirectToPage();
    }

    public IActionResult OnPostRemove(int productId)
    {
        _cartService.RemoveItem(productId);
        return RedirectToPage();
    }

    public IActionResult OnPostClear()
    {
        _cartService.Clear();
        return RedirectToPage();
    }
}
```

### Pages/Cart.cshtml

```html
@page
@model CartModel
@{
    ViewData["Title"] = "Shopping Cart";
}

<div class="container py-4">
    <h1 class="fw-bold mb-4">🛒 Shopping Cart</h1>

    @if (Model.Items.Count == 0)
    {
        <div class="text-center py-5">
            <p class="fs-4 text-muted">Your cart is empty</p>
            <a asp-page="/Index" class="btn btn-success btn-lg mt-3">Start Shopping</a>
        </div>
    }
    else
    {
        <div class="table-responsive">
            <table class="table align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Product</th>
                        <th>Price</th>
                        <th style="width: 150px;">Quantity</th>
                        <th>Subtotal</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @foreach (var item in Model.Items)
                    {
                        <tr>
                            <td>
                                <div class="d-flex align-items-center">
                                    <img src="@item.ImageUrl" alt="@item.ProductName" class="rounded me-3"
                                         style="width: 60px; height: 45px; object-fit: cover;" />
                                    <a asp-page="/ProductDetail" asp-route-id="@item.ProductId"
                                       class="text-decoration-none text-dark fw-semibold">@item.ProductName</a>
                                </div>
                            </td>
                            <td>@item.Price.ToString("C")</td>
                            <td>
                                <form method="post" asp-page-handler="UpdateQuantity" class="d-flex align-items-center">
                                    <input type="hidden" name="productId" value="@item.ProductId" />
                                    <input type="number" name="quantity" value="@item.Quantity" min="1" max="99"
                                           class="form-control form-control-sm" style="width: 70px;" />
                                    <button type="submit" class="btn btn-sm btn-outline-success ms-2">Update</button>
                                </form>
                            </td>
                            <td class="fw-bold">@item.Subtotal.ToString("C")</td>
                            <td>
                                <form method="post" asp-page-handler="Remove">
                                    <input type="hidden" name="productId" value="@item.ProductId" />
                                    <button type="submit" class="btn btn-sm btn-outline-danger">Remove</button>
                                </form>
                            </td>
                        </tr>
                    }
                </tbody>
            </table>
        </div>

        <div class="row mt-4">
            <div class="col-md-6">
                <form method="post" asp-page-handler="Clear">
                    <button type="submit" class="btn btn-outline-secondary">Clear Cart</button>
                </form>
            </div>
            <div class="col-md-6 text-end">
                <p class="fs-4 fw-bold">Total: <span class="text-success">@Model.Total.ToString("C")</span></p>
                <div class="mt-3">
                    <a asp-page="/Index" class="btn btn-outline-success me-2">Continue Shopping</a>
                    <a asp-page="/Checkout" class="btn btn-success btn-lg">Proceed to Checkout</a>
                </div>
            </div>
        </div>
    }
</div>
```

---

## Step 10: Create the Checkout Page

The checkout page collects shipping and payment information. Since this is a demo, payment fields are not validated — any values are accepted.

### Pages/Checkout.cshtml.cs

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using RazorPages.Models;
using RazorPages.Services;

namespace RazorPages.Pages;

public class CheckoutModel : PageModel
{
    private readonly CartService _cartService;

    public CheckoutModel(CartService cartService)
    {
        _cartService = cartService;
    }

    [BindProperty]
    public CheckoutInfo CheckoutInfo { get; set; } = new();

    public List<CartItem> CartItems { get; set; } = [];
    public decimal Total { get; set; }

    public IActionResult OnGet()
    {
        CartItems = _cartService.GetItems();
        if (CartItems.Count == 0)
        {
            return RedirectToPage("/Cart");
        }
        Total = _cartService.GetTotal();
        return Page();
    }

    public IActionResult OnPost()
    {
        CartItems = _cartService.GetItems();
        Total = _cartService.GetTotal();

        if (CartItems.Count == 0)
        {
            return RedirectToPage("/Cart");
        }

        // Demo app — no real validation on payment info.
        // Just clear the cart and show success.
        _cartService.Clear();
        return RedirectToPage("/OrderConfirmation");
    }
}
```

### Pages/Checkout.cshtml

```html
@page
@model CheckoutModel
@{
    ViewData["Title"] = "Checkout";
}

<div class="container py-4">
    <h1 class="fw-bold mb-4">Checkout</h1>

    <form method="post">
        <div class="row g-4">
            <!-- Shipping & Payment Form -->
            <div class="col-lg-7">
                <!-- Shipping Information -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header bg-success text-white fw-bold">
                        📦 Shipping Information
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label for="fullName" class="form-label">Full Name</label>
                            <input asp-for="CheckoutInfo.FullName" class="form-control" id="fullName" placeholder="John Doe" />
                        </div>
                        <div class="mb-3">
                            <label for="email" class="form-label">Email Address</label>
                            <input asp-for="CheckoutInfo.Email" type="email" class="form-control" id="email" placeholder="john@example.com" />
                        </div>
                        <div class="mb-3">
                            <label for="address" class="form-label">Street Address</label>
                            <input asp-for="CheckoutInfo.Address" class="form-control" id="address" placeholder="123 Trail Lane" />
                        </div>
                        <div class="row">
                            <div class="col-md-5 mb-3">
                                <label for="city" class="form-label">City</label>
                                <input asp-for="CheckoutInfo.City" class="form-control" id="city" placeholder="Denver" />
                            </div>
                            <div class="col-md-3 mb-3">
                                <label for="state" class="form-label">State</label>
                                <input asp-for="CheckoutInfo.State" class="form-control" id="state" placeholder="CO" />
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="zipCode" class="form-label">ZIP Code</label>
                                <input asp-for="CheckoutInfo.ZipCode" class="form-control" id="zipCode" placeholder="80202" />
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="country" class="form-label">Country</label>
                            <input asp-for="CheckoutInfo.Country" class="form-control" id="country" placeholder="United States" />
                        </div>
                    </div>
                </div>

                <!-- Payment Information -->
                <div class="card shadow-sm">
                    <div class="card-header bg-success text-white fw-bold">
                        💳 Payment Information
                    </div>
                    <div class="card-body">
                        <div class="alert alert-info small mb-3">
                            🏔️ This is a demo app — no real payment is processed. Enter any values.
                        </div>
                        <div class="mb-3">
                            <label for="cardholderName" class="form-label">Cardholder Name</label>
                            <input asp-for="CheckoutInfo.CardholderName" class="form-control" id="cardholderName" placeholder="John Doe" />
                        </div>
                        <div class="mb-3">
                            <label for="cardNumber" class="form-label">Card Number</label>
                            <input asp-for="CheckoutInfo.CardNumber" class="form-control" id="cardNumber" placeholder="4111 1111 1111 1111" />
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="expirationDate" class="form-label">Expiration Date</label>
                                <input asp-for="CheckoutInfo.ExpirationDate" class="form-control" id="expirationDate" placeholder="MM/YY" />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="cvv" class="form-label">CVV</label>
                                <input asp-for="CheckoutInfo.Cvv" class="form-control" id="cvv" placeholder="123" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Order Summary -->
            <div class="col-lg-5">
                <div class="card shadow-sm sticky-top" style="top: 1rem;">
                    <div class="card-header bg-light fw-bold">
                        🧾 Order Summary
                    </div>
                    <div class="card-body">
                        @foreach (var item in Model.CartItems)
                        {
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <div>
                                    <span class="fw-semibold">@item.ProductName</span>
                                    <small class="text-muted d-block">Qty: @item.Quantity</small>
                                </div>
                                <span>@item.Subtotal.ToString("C")</span>
                            </div>
                        }
                        <hr />
                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Total</span>
                            <span class="text-success">@Model.Total.ToString("C")</span>
                        </div>
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-success btn-lg w-100">Place Order</button>
                        <a asp-page="/Cart" class="btn btn-outline-secondary w-100 mt-2">← Back to Cart</a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>
```

---

## Step 11: Create the Order Confirmation Page

### Pages/OrderConfirmation.cshtml.cs

```csharp
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace RazorPages.Pages;

public class OrderConfirmationModel : PageModel
{
    public void OnGet()
    {
    }
}
```

### Pages/OrderConfirmation.cshtml

```html
@page
@model OrderConfirmationModel
@{
    ViewData["Title"] = "Order Confirmed";
}

<div class="container py-5 text-center">
    <div class="mx-auto" style="max-width: 600px;">
        <div class="display-1 mb-3">🎉</div>
        <h1 class="fw-bold text-success">Order Confirmed!</h1>
        <p class="lead text-muted mt-3">
            Thank you for shopping with HikeR! Your order has been placed successfully.
        </p>
        <p class="text-muted">
            This is a demo application — no real order has been processed and no payment has been charged.
        </p>
        <div class="mt-4">
            <a asp-page="/Index" class="btn btn-success btn-lg">🥾 Continue Shopping</a>
        </div>
    </div>
</div>
```

---

## Step 12: Update the Layout for HikeR Branding

Update `Pages/Shared/_Layout.cshtml`:

1. Change the page `<title>` from `RazorPages` to `HikeR`:
   ```html
   <title>@ViewData["Title"] - HikeR</title>
   ```

2. Change the navbar brand:
   ```html
   <a class="navbar-brand fw-bold" asp-area="" asp-page="/Index">🥾 HikeR</a>
   ```

3. Update the nav links — rename "Home" to "Shop", keep "Privacy", and add a Cart button on the right side of the navbar:
   ```html
   <ul class="navbar-nav flex-grow-1">
       <li class="nav-item">
           <a class="nav-link text-white" asp-area="" asp-page="/Index">Shop</a>
       </li>
       <li class="nav-item">
           <a class="nav-link text-white" asp-area="" asp-page="/Privacy">Privacy</a>
       </li>
   </ul>
   <a asp-page="/Cart" class="btn btn-outline-light btn-sm">
       🛒 Cart
   </a>
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

## Step 13: Update the Privacy Page

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

## Step 14: Update CSS for Outdoor Theme

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

1. **Home page** shows a product grid with 15+ hiking products, category filter buttons, "Add" cart buttons, and the HikeR branding
2. **Clicking a product** navigates to the detail page with full product info, breadcrumb navigation, and an "Add to Cart" button
3. **Category filters** correctly filter the product list
4. **Navbar** shows "🥾 HikeR" brand with green background and a 🛒 Cart button
5. **Add to Cart** — clicking "Add" on the catalog or "Add to Cart" on the detail page adds items to the cart
6. **Cart page** shows all added items with quantities, subtotals, and a total. Users can update quantities, remove items, or clear the cart
7. **Checkout page** — clicking "Proceed to Checkout" shows a form with shipping info (name, email, address, city, state, zip, country) and payment info (cardholder name, card number, expiration, CVV) alongside an order summary
8. **Place Order** — clicking "Place Order" clears the cart and shows the Order Confirmation success page
9. **Order Confirmation** shows a success message and a link to continue shopping
10. **Footer** shows "HikeR — Your Trail Starts Here"
11. **Privacy page** shows HikeR-branded privacy text
