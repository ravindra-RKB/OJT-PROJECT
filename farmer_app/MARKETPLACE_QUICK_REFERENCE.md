# Quick Reference - Marketplace Features

## 🛒 Buyer Journey

```
START
  ↓
Browse Products (/marketplace)
  ↓
Select Product → View Details
  ↓
Choose Quantity
  ↓
Select Action:
  ├── Add to Cart → /cart → /checkout
  └── Buy Now → /checkout
  ↓
/checkout (Delivery & Payment)
  ├── Enter Name, Email, Phone
  ├── Enter Delivery Address, City, State, ZIP
  ├── Select Payment (COD / Online)
  ├── Accept Terms
  └── Place Order
  ↓
Order Created ✓
  ├── Order ID: #XXXXXXXX
  └── Status: Pending
  ↓
/my-orders (Track Order)
  ├── View Order Details
  ├── See Status Timeline
  ├── Track Shipment
  └── Cancel (if not shipped)
```

## 🌾 Seller Journey

```
START
  ↓
Add Products (/seller/add-product)
  ├── Photos
  ├── Name, Description, Price
  ├── Quantity, Category
  └── Location
  ↓
Products Listed → Visible in /marketplace
  ↓
Receive Orders → /seller/orders
  ├── Order Status: Pending
  ├── Buyer Info: Name, Email, Phone
  ├── Items: Product, Quantity, Price
  └── Delivery Address
  ↓
Manage Order → Click "Manage Order"
  ├── Step 1: "Confirm Order" → Status: Confirmed
  ├── Step 2: Add Tracking Number → "Ship Order" → Status: Shipped
  ├── Step 3: "Mark as Delivered" → Status: Delivered
  └── Done ✓
```

## 📊 Order Status Reference

| Status | Seller Action | Buyer View | Can Cancel? |
|--------|---------------|-----------|------------|
| **Pending** | Confirm or Ignore | Awaiting Confirmation | ✅ Yes |
| **Confirmed** | Add Tracking & Ship | Confirmed, Preparing | ✅ Yes |
| **Shipped** | Wait for Delivery | In Transit | ❌ No |
| **Delivered** | Complete | Received ✓ | ❌ No |
| **Cancelled** | N/A | Order Cancelled | N/A |

## 🔑 Key Files

| File | Purpose | Lines |
|------|---------|-------|
| `order.dart` | Data models | 223 |
| `order_service.dart` | Database operations | 178 |
| `order_provider.dart` | State management | 271 |
| `checkout_page.dart` | Checkout UI | 462 |
| `order_tracking_page.dart` | Buyer's orders | 546 |
| `seller_orders_page.dart` | Seller dashboard | 588 |

## 🛣️ Routes

```dart
/marketplace          → Browse all products
/checkout            → Checkout page
/my-orders           → Buyer's order history
/seller/orders       → Seller's order management
/seller/add-product  → Add new product
```

## 💻 API Methods

### OrderProvider Methods
```dart
// Buyers
loadBuyerOrders(userId)          // Load buyer's orders
getOrder(orderId)                // Get single order
cancelOrder(orderId)             // Cancel order

// Sellers
loadSellerOrders(sellerId)       // Load seller's orders
updateOrderStatus(orderId, status)  // Change status
addTrackingNumber(orderId, number)  // Add tracking
```

### OrderService Methods
```dart
// Creation
createOrder(...)                 // Create new order

// Reading
getOrderById(orderId)            // Get order details
getBuyerOrders(buyerId)          // Get buyer's orders
getSellerOrders(sellerId)        // Get seller's orders

// Updating
updateOrderStatus(...)           // Change order status
updatePaymentStatus(...)         // Update payment status
addTrackingNumber(...)           // Add tracking info
cancelOrder(...)                 // Cancel and restore inventory
```

## 📦 Order Data Structure

```json
{
  "id": "unique_order_id",
  "buyerId": "user_uid",
  "buyerName": "Name",
  "buyerEmail": "email@example.com",
  "buyerPhone": "9876543210",
  "items": [
    {
      "productId": "prod_id",
      "productName": "Tomatoes",
      "price": 50,
      "quantity": 5,
      "sellerId": "farmer_uid"
    }
  ],
  "totalAmount": 250,
  "status": "pending|confirmed|shipped|delivered|cancelled",
  "deliveryAddress": "Street Address",
  "city": "City",
  "state": "State",
  "zipCode": "123456",
  "paymentMethod": "cod|online",
  "paymentStatus": "pending|completed",
  "createdAt": "timestamp",
  "shippedAt": "timestamp",
  "trackingNumber": "tracking_id"
}
```

## ✨ Features Checklist

### Buyer Features
- [x] Browse products
- [x] View product details
- [x] Add to cart
- [x] Buy now (direct checkout)
- [x] Checkout with delivery address
- [x] Choose payment method (COD)
- [x] Place order
- [x] Track order status
- [x] View tracking number
- [x] Cancel order
- [x] Order history

### Seller Features
- [x] Add products with images
- [x] Manage inventory
- [x] Receive orders
- [x] Confirm orders
- [x] Add tracking & ship
- [x] Mark as delivered
- [x] View buyer info
- [x] Filter orders by status
- [x] Order statistics
- [x] Auto inventory deduction
- [x] Auto inventory restoration

## 🚨 Important Notes

1. **Inventory**: Automatically reduced when order placed, restored when cancelled
2. **Order ID**: First 8 chars of Firestore doc ID shown as #XXXXXXXX
3. **Real-time**: Uses Firestore Streams for live updates
4. **Payment**: COD ready, Online payment requires gateway integration
5. **Status Flow**: Pending → Confirmed → Shipped → Delivered (or Cancelled at any point before shipped)

## 🎯 Testing Commands

### Buyer Testing
1. Go to /marketplace
2. Click any product → View details
3. Increase quantity → Click "Buy Now"
4. Fill checkout form → Click "Place Order"
5. Go to /my-orders → See order with "Pending" status

### Seller Testing
1. Go to /seller/orders
2. Find the order just created
3. Click "Manage Order"
4. Click "Confirm Order" → Status becomes "Confirmed"
5. Add tracking number → Click "Ship Order" → Status becomes "Shipped"
6. Click "Mark as Delivered" → Status becomes "Delivered"

### Buyer Verification
1. Go to /my-orders
2. Refresh → See updated status
3. Order shows "Shipped" with tracking number
4. Order shows "Delivered"

## 📱 UI Components

### Checkout Page
- Order summary card
- Address form fields
- Payment method selection
- Terms checkbox
- Place order button
- Success dialog

### Order Tracking Page
- Order list with status badges
- Status timeline visualization
- Item details with images
- Delivery address card
- Tracking number display
- Cancel order button

### Seller Orders
- Filter chips (All/Pending/Confirmed/Shipped/Delivered)
- Order cards with buyer name & total
- View details button
- Action buttons based on status
- Tracking input field

## 🔄 Data Flow

```
Product Added
    ↓
Shows in /marketplace
    ↓
Buyer clicks "Buy Now"
    ↓
Goes to /checkout
    ↓
Fills address → Place Order
    ↓
Order created in Firestore
    ↓
Product quantity deducted
    ↓
Order appears in /seller/orders (Pending)
    ↓
Seller confirms → Status: Confirmed
    ↓
Seller adds tracking → Status: Shipped
    ↓
Seller marks delivered → Status: Delivered
    ↓
Buyer sees in /my-orders with Delivered status
```

## 💡 Pro Tips

1. **Cart Persistence**: Cart is in memory, clears on app restart (can add local storage if needed)
2. **Real-time Updates**: Enable Firestore offline persistence for better UX
3. **Notifications**: Use Firebase Cloud Messaging for order status notifications
4. **Payment**: Use Razorpay SDK for secure online payments
5. **Analytics**: Track sales, popular products, buyer patterns

---

**Last Updated**: December 2, 2025
**Status**: Production Ready ✅
**Version**: 1.0.0
