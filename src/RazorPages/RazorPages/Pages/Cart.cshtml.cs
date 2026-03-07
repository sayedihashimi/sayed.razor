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
