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
