# Supabase Migration Guide

This document provides a complete migration path from Firebase to Supabase for the Farmer App. Follow the steps below to set up Supabase tables and migrate your data.

---

## Prerequisites

1. Create a Supabase account at [https://supabase.com](https://supabase.com).
2. Create a new Supabase project.
3. Get your **Project URL** and **Anon Key** from Supabase dashboard (Settings → API).
4. Create a `.env` file in `farmer_app/` with:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   CLOUDINARY_CLOUD_NAME=your-cloud-name
   CLOUDINARY_UPLOAD_PRESET=your-upload-preset
   ```

---

## Step 1: Create Supabase Tables

Run the following SQL in your Supabase project's SQL Editor to create all required tables.

### 1.1 Products Table

```sql
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sellerId TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price DOUBLE PRECISION NOT NULL,
  unit TEXT NOT NULL,
  images JSONB DEFAULT '[]'::jsonb,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  address TEXT,
  availableQuantity INTEGER DEFAULT 0,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_products_seller ON products(sellerId);
CREATE INDEX idx_products_category ON products(category);
```

### 1.2 Orders Table

```sql
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyerId TEXT NOT NULL,
  buyerName TEXT NOT NULL,
  buyerEmail TEXT NOT NULL,
  buyerPhone TEXT NOT NULL,
  items JSONB DEFAULT '[]'::jsonb,
  totalAmount DOUBLE PRECISION NOT NULL,
  status TEXT DEFAULT 'pending',
  deliveryAddress TEXT,
  city TEXT,
  state TEXT,
  zipCode TEXT,
  paymentMethod TEXT DEFAULT 'cod',
  paymentStatus TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  confirmedAt TIMESTAMP WITH TIME ZONE,
  shippedAt TIMESTAMP WITH TIME ZONE,
  deliveredAt TIMESTAMP WITH TIME ZONE,
  cancelledAt TIMESTAMP WITH TIME ZONE,
  trackingNumber TEXT,
  notes TEXT
);

CREATE INDEX idx_orders_buyer ON orders(buyerId);
CREATE INDEX idx_orders_status ON orders(status);
```

### 1.3 User Profiles Table

```sql
CREATE TABLE IF NOT EXISTS user_profiles (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  displayName TEXT,
  photoUrl TEXT,
  phone TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  zipCode TEXT,
  userType TEXT DEFAULT 'buyer',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_profiles_email ON user_profiles(email);
```

### 1.4 Farm Diary Table

```sql
CREATE TABLE IF NOT EXISTS farm_diary_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  userId TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  weather TEXT,
  tasksDone JSONB DEFAULT '[]'::jsonb,
  images JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_diary_user ON farm_diary_entries(userId);
```

### 1.5 Schemes Table

```sql
CREATE TABLE IF NOT EXISTS government_schemes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  eligibility TEXT,
  benefits TEXT,
  applicationLink TEXT,
  category TEXT,
  state TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_schemes_state ON government_schemes(state);
CREATE INDEX idx_schemes_category ON government_schemes(category);
```

### 1.6 Mandi Prices Table

```sql
CREATE TABLE IF NOT EXISTS mandi_prices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity TEXT NOT NULL,
  market TEXT NOT NULL,
  price DOUBLE PRECISION NOT NULL,
  unit TEXT DEFAULT 'quintal',
  minPrice DOUBLE PRECISION,
  maxPrice DOUBLE PRECISION,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  date DATE DEFAULT CURRENT_DATE
);

CREATE INDEX idx_mandi_commodity ON mandi_prices(commodity);
CREATE INDEX idx_mandi_market ON mandi_prices(market);
```

---

## Step 2: Enable Row Level Security (RLS)

For production, enable RLS on all tables. For development/testing, you can temporarily disable it:

```sql
-- Disable RLS for testing (NOT recommended for production)
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE farm_diary_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE government_schemes DISABLE ROW LEVEL SECURITY;
ALTER TABLE mandi_prices DISABLE ROW LEVEL SECURITY;
```

---

## Step 3: Set Up Environment Variables

Update `farmer_app/.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
CLOUDINARY_CLOUD_NAME=your-cloudinary-cloud-name
CLOUDINARY_UPLOAD_PRESET=your-unsigned-upload-preset
```

---

## Step 4: Run Flutter App

```bash
cd farmer_app
flutter pub get
flutter run
```

---

## Migration Checklist

### Services Already Migrated

- ✅ **AuthProvider** — Uses `SupabaseService` for sign-in/sign-up/sign-out
- ✅ **ProductService** — Has `createProductSupabase()` and product Cloudinary upload
- ✅ **OrderService** — Has `createOrderSupabase()`, `getBuyerOrdersSupabase()`, `updateOrderStatusSupabase()`

### Services Needing Migration

- ⏳ **ProductService** — Add `getProductsSupabase()`, `streamProductsSupabase()`, `updateProductSupabase()`, `deleteProductSupabase()`
- ⏳ **ProfileService** — Migrate user profile CRUD from Firestore to Supabase
- ⏳ **DiaryService** — Migrate farm diary entries from Firestore to Supabase
- ⏳ **SchemeService** — Migrate government schemes from Firestore to Supabase
- ⏳ **MandiService** — Migrate mandi prices from Firestore to Supabase
- ⏳ **WeatherService** — Check if any Firestore usage; migrate if needed

### Final Cleanup

- Remove `firebase_core`, `firebase_auth`, `cloud_firestore` from `pubspec.yaml`
- Delete `firebase_options.dart`
- Delete `google-services.json` from Android
- Delete `GoogleService-Info.plist` from iOS
- Update platform plugin registrants (Windows/macOS)

---

## Testing & Validation

1. **Test Auth Flow**: Sign up / sign in with Supabase.
2. **Test Product Creation**: Create a product on seller page; verify in Supabase dashboard.
3. **Test Product View**: View products on marketplace; verify data loads correctly.
4. **Test Orders**: Create an order; verify quantities decrement and order appears in buyer's order list.
5. **Run Analyzer**: `flutter analyze` should report only informational hints.

---

## Troubleshooting

### "SUPABASE_URL not set in environment"

- Ensure `.env` file exists in `farmer_app/` directory.
- Run `flutter pub get` to re-load dotenv.

### "Supabase insert returned null"

- Verify table schema matches the expected column names.
- Check that `.select().maybeSingle()` is used after `.insert()`.

### "Cloudinary upload failed"

- Verify `CLOUDINARY_CLOUD_NAME` and `CLOUDINARY_UPLOAD_PRESET` are correct.
- Ensure upload preset is set to **unsigned** (no auth required).

### Row Level Security (RLS) blocking queries

- Temporarily disable RLS for testing: `ALTER TABLE <table> DISABLE ROW LEVEL SECURITY;`
- For production, set up proper RLS policies based on user roles.

---

## Data Migration from Firebase (Optional)

If you have existing Firebase data you want to migrate:

1. Export Firestore collections as JSON from Firebase Console.
2. Transform JSON to match Supabase table schemas.
3. Use Supabase's import tools or write a migration script to populate tables.

---

## Next Steps

1. Create tables in Supabase using the SQL above.
2. Set environment variables in `.env`.
3. Run `flutter pub get` and test auth flow.
4. Iterate migration of remaining services one-by-one.
5. Once all services are migrated, remove Firebase packages from `pubspec.yaml`.
