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
