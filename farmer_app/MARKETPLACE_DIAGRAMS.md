# Marketplace Architecture & Flow Diagrams

## 1. System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FarmHub Marketplace                       │
├─────────────────────────────────────────────────────────────┤
│                          Flutter UI Layer                    │
├──────────────────────┬──────────────────┬───────────────────┤
│   Buyer Pages       │  Seller Pages     │   Shared Pages   │
├──────────────────────┼──────────────────┼───────────────────┤
│ • ProductListPage   │ • AddProductPage  │ • HomePage       │
│ • ProductDetail     │ • SellerOrders    │ • ProfilePage    │
│ • CheckoutPage      │ • OrderManage     │ • CartPage       │
│ • OrderTracking     │                   │                  │
└──────────────────────┴──────────────────┴───────────────────┘
          ↓                    ↓                    ↓
┌─────────────────────────────────────────────────────────────┐
│              Provider & State Management Layer                │
├─────────────────────────────────────────────────────────────┤
│  AuthProvider │ CartProvider │ OrderProvider │ OtherProviders│
└─────────────────────────────────────────────────────────────┘
          ↓                    ↓
┌─────────────────────────────────────────────────────────────┐
│            Services Layer (Business Logic)                   │
├──────────────────────────────────────────────────────────────┤
│ ProductService │ OrderService │ Other Services              │
└──────────────────────────────────────────────────────────────┘
          ↓                    ↓
┌─────────────────────────────────────────────────────────────┐
│              Firebase Firestore Database                     │
├──────────────────────────────────────────────────────────────┤
│ ┌────────────┐ ┌────────────┐ ┌────────────┐              │
│ │  products  │ │  orders    │ │   users    │              │
│ └────────────┘ └────────────┘ └────────────┘              │
└──────────────────────────────────────────────────────────────┘
```

## 2. Order Creation Flow (Detailed)

```
┌──────────────────────────────────────────────────────────────┐
│ Buyer clicks "Buy Now" on Product Detail                     │
└──────────────┬───────────────────────────────────────────────┘
               ↓
┌──────────────────────────────────────────────────────────────┐
│ Add items to cart                                            │
│ CartProvider.add(product) called multiple times            │
└──────────────┬───────────────────────────────────────────────┘
               ↓
┌──────────────────────────────────────────────────────────────┐
│ Navigate to /checkout (CheckoutPage)                        │
│ Display order summary & form                                │
└──────────────┬───────────────────────────────────────────────┘
               ↓
┌──────────────────────────────────────────────────────────────┐
│ User fills delivery details:                                │
│ • Name, Email, Phone                                        │
│ • Address, City, State, ZIP                                 │
│ • Selects Payment Method (COD/Online)                       │
│ • Accepts Terms                                             │
└──────────────┬───────────────────────────────────────────────┘
               ↓
┌──────────────────────────────────────────────────────────────┐
│ Click "Place Order"                                          │
└──────────────┬───────────────────────────────────────────────┘
               ↓
┌──────────────────────────────────────────────────────────────┐
│ OrderProvider.createOrder() called                          │
│ ├─ OrderService.createOrder() creates Firestore doc        │
│ ├─ Convert CartItems to OrderItems                         │
│ ├─ FOR EACH item:                                          │
│ │  └─ Deduct quantity from product.availableQuantity       │
│ └─ Return Order object                                     │
└──────────────┬───────────────────────────────────────────────┘
               ↓
┌──────────────────────────────────────────────────────────────┐
│ Order Created Successfully!                                 │
│ Show Confirmation Dialog with Order #XXXXXXXX              │
└──────────────┬───────────────────────────────────────────────┘
               ↓
┌──────────────────────────────────────────────────────────────┐
│ Clear cart & navigate to /home or /my-orders                │
└──────────────────────────────────────────────────────────────┘
```

## 3. Order Status Lifecycle

```
                          ┌─────────────┐
                          │   PENDING   │
                          │ (Awaiting   │
                          │  Seller)    │
                          └──────┬──────┘
                                 │
                    ┌────────────┴───────────────┐
                    │                           │
                    ↓                           ↓
            ┌─────────────┐         ┌────────────────┐
            │ CONFIRMED   │         │   CANCELLED    │
            │(Seller      │         │(Order Refunded)│
            │ Confirmed)  │         └────────────────┘
            └──────┬──────┘
                   │
         ┌─────────┴────────────┐
         │(Add Tracking Number) │
         ↓                      ↓
    ┌──────────┐       ┌─────────────┐
    │ SHIPPED  │       │ CANCELLED   │
    │(In       │       │(Order       │
    │ Transit) │       │ Cancelled)  │
    └────┬─────┘       └─────────────┘
         │
         ↓
    ┌──────────────┐
    │  DELIVERED   │
    │(Buyer        │
    │ Received)    │
    └──────────────┘
```

## 4. Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CheckoutPage                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ _formKey: GlobalKey<FormState>                      │  │
│  │ _nameCtrl, _emailCtrl, etc...                       │  │
│  │ _paymentMethod: String                             │  │
│  │ _agreeToTerms: bool                                │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────────┬───────────────────────────────────────────┘
                   │
    ┌──────────────┴──────────────┐
    │                             │
    ↓                             ↓
┌──────────────┐       ┌──────────────────┐
│ CartProvider │       │ OrderProvider    │
│              │       │                  │
│ • items[]    │       │ .createOrder()   │
│ .total       │       │ .updateStatus()  │
│ .clear()     │       │ .addTracking()   │
└──────┬───────┘       └────────┬─────────┘
       │                        │
       └───────────┬────────────┘
                   ↓
        ┌──────────────────────┐
        │   OrderService       │
        │                      │
        │ .createOrder()       │
        │ .updateStatus()      │
        │ .cancelOrder()       │
        └───────────┬──────────┘
                    │
                    ↓
        ┌──────────────────────┐
        │  Firebase Firestore  │
        │                      │
        │  {orders collection} │
        └──────────────────────┘
```

## 5. Data Model Relationships

```
┌────────────────────────────────────────────┐
│            User (Auth)                      │
│ ┌──────────────────────────────────────┐  │
│ │ uid, displayName, email, photoURL    │  │
│ └──────────────────────────────────────┘  │
└─────────────────┬────────────────────────┬─┘
                  │                        │
          ┌───────┴──────┐         ┌───────┴──────┐
          │              │         │              │
          ↓              ↓         ↓              ↓
     [Buyer]        [Seller]  [Farmer]      [Admin]
          │              │
          │              └──────────┬─────────────┐
          │                         │             │
          ↓                         ↓             ↓
    ┌──────────┐           ┌──────────┐    ┌──────────┐
    │  Order   │           │ Product  │    │  Order   │
    │  (has    │◄──────────│  (has    │    │ (manages)│
    │  many)   │           │ many in  │    │          │
    └────┬─────┘           │ each)    │    └──────────┘
         │                 └────┬─────┘
         │                      │
         ↓                      ↓
    ┌──────────┐         ┌──────────┐
    │OrderItem │         │OrderItem │
    │(has one) │         │(has one) │
    └──────────┘         └──────────┘
         │                      │
         └──────────┬───────────┘
                    ↓
         (References ProductId)
```

## 6. Page Navigation Flow

```
                    ┌─────────────────┐
                    │   HomePage      │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ↓                   ↓                   ↓
    ┌──────────┐      ┌────────────┐    ┌────────────┐
    │Marketplace│      │FarmDiary   │    │Profile     │
    │(Browse)   │      │   Page     │    │Page        │
    └─────┬─────┘      └────────────┘    └────────────┘
          │
          ↓
    ┌──────────────────┐
    │ProductDetail     │
    └─────┬────────────┘
          │
    ┌─────┴──────────────┐
    │                    │
    ↓                    ↓
[Add to Cart]   ┌─────────────────┐
    │           │  Buy Now        │
    │           └────────┬────────┘
    │                    │
    └─────────┬──────────┘
              │
              ↓
         ┌──────────┐
         │ CheckOut │
         └─────┬────┘
              │
              ↓
         ┌────────────┐
         │MyOrders    │
         │(Tracking)  │
         └────────────┘
```

## 7. Seller Order Management Flow

```
┌────────────────────────────────────┐
│      /seller/orders Page           │
│   (Seller Orders Dashboard)        │
└────────────┬───────────────────────┘
             │
    ┌────────┴─────────┬────────────┐
    │                  │            │
    ↓                  ↓            ↓
 Filter      Order Card    Statistics
  By         (Status,      (Total,
 Status      Buyer Info,   Pending,
             Amount)       Shipped,
    │           │          Delivered)
    │           │
    │           ↓
    └──►┌────────────────────┐
        │  Order Detail Page │
        └────────┬───────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ↓            ↓            ↓
Pending     Confirmed      Shipped
  │            │             │
  ├─►[Confirm] ├►[Add        ├►[Mark
  │  Order     │  Tracking]  │ Delivered]
  │  Button    │  [Ship]     │
  │            │  Button     │
  ↓            ↓             ↓
Status:    Status:        Status:
Confirmed  Shipped       Delivered
                         ✓ ORDER
                         COMPLETE
```

## 8. Firestore Collections Structure

```
Root Firestore
│
├── products (collection)
│   ├── product_id_1 (doc)
│   │   ├── name: "Tomato"
│   │   ├── price: 50
│   │   ├── availableQuantity: 100
│   │   ├── sellerId: "farmer_123"
│   │   └── images: ["url1", "url2"]
│   │
│   └── product_id_2 (doc)
│       └── ...
│
├── orders (collection)
│   ├── order_abc123 (doc)
│   │   ├── buyerId: "user_456"
│   │   ├── buyerName: "John"
│   │   ├── items: [
│   │   │   {
│   │   │     productId: "prod_1",
│   │   │     productName: "Tomato",
│   │   │     quantity: 5,
│   │   │     sellerId: "farmer_123"
│   │   │   }
│   │   │ ]
│   │   ├── totalAmount: 250
│   │   ├── status: "pending"
│   │   ├── deliveryAddress: "123 Lane"
│   │   ├── createdAt: timestamp
│   │   └── trackingNumber: null
│   │
│   └── order_def456 (doc)
│       └── ...
│
└── users (collection)
    ├── user_123 (doc)
    │   ├── displayName: "John"
    │   ├── email: "john@example.com"
    │   └── role: "buyer"
    │
    └── farmer_456 (doc)
        ├── displayName: "Farmer Jane"
        ├── email: "jane@farm.com"
        └── role: "seller"
```

## 9. State Management Flow

```
┌────────────────────────────────────┐
│  User Action (Tap Button)          │
└─────────────┬──────────────────────┘
              │
              ↓
        ┌──────────────┐
        │  Widget      │
        │  (Page)      │
        └──────┬───────┘
               │
               ↓
    ┌─────────────────────┐
    │  Provider Listener  │
    │  (Consumer)         │
    └──────────┬──────────┘
               │
               ↓
    ┌──────────────────────────┐
    │  OrderProvider Method    │
    │  (loadOrders, create     │
    │   updateStatus, etc)     │
    └──────────┬───────────────┘
               │
               ↓
    ┌──────────────────────────┐
    │  OrderService Method     │
    │  (Firestore operation)   │
    └──────────┬───────────────┘
               │
               ↓
    ┌──────────────────────────┐
    │  Firestore Database      │
    │  (Create/Update/Read doc)│
    └──────────┬───────────────┘
               │
               ↓
    ┌──────────────────────────┐
    │  notifyListeners()       │
    │  (Provider broadcasts    │
    │   state change)          │
    └──────────┬───────────────┘
               │
               ↓
    ┌──────────────────────────┐
    │  Consumer rebuilds       │
    │  Widget with new state   │
    └──────────────────────────┘
```

---

**Diagram Types**: Architecture, Flow, Navigation, Data Models, Database Schema, State Management
**Status**: Complete and Production Ready ✅
