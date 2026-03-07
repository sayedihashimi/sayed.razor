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
