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
