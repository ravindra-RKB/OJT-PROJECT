# Supabase Quick Start Guide - Step by Step

Follow this guide to create a Supabase project and connect it to your Farmer App.

---

## Step 1: Create Supabase Account & Project

### 1.1 Sign Up
1. Go to **[https://supabase.com](https://supabase.com)**
2. Click **"Sign Up"** (top right)
3. Choose **"Continue with GitHub"** or create an email account
4. Verify your email if needed

### 1.2 Create Your First Project
1. After login, you'll see the dashboard
2. Click **"New Project"** button
3. Fill in the form:
   - **Organization**: Choose existing or create new
   - **Project Name**: `farmer-app` (or any name you prefer)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to your location (e.g., `ap-south-1` for India, or `us-east-1`)
4. Click **"Create New Project"**
5. Wait 1-2 minutes for the project to initialize...

---

## Step 2: Get Your Credentials

Once your project is ready, you need to get your **API credentials**.

### 2.1 Find Your Project URL & Keys
1. In your Supabase dashboard, go to **Settings** (bottom left sidebar)
2. Click **"API"** in the left menu
3. You'll see:
   - **Project URL**: Copy this (looks like `https://your-project-id.supabase.co`)
   - **Anon/Public Key**: Copy this (long string starting with `eyJ...`)

### 2.2 Save These Values
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Step 3: Create Database Tables

### 3.1 Open SQL Editor
1. In your Supabase project dashboard, find the **SQL Editor** (left sidebar)
2. Click **"New Query"** button

### 3.2 Copy & Paste SQL

Copy the entire SQL block below and paste it into the SQL Editor:

```sql
-- Create products table
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

-- Create orders table
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

-- Create user profiles table
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

-- Create farm diary table
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

-- Create government schemes table
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

-- Create mandi prices table
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

### 3.3 Run the SQL
1. Click the **"Run"** button (or press `Ctrl+Enter`)
2. You should see a success message: `"Successfully executed 1 statement"`
3. Tables are now created!

---

## Step 4: Disable Row Level Security (RLS) for Testing

For development/testing, we'll disable RLS. **Do NOT do this in production!**

### 4.1 Disable RLS
1. Go to **Authentication** in the left sidebar
2. Click **"Policies"**
3. For each table (products, orders, user_profiles, farm_diary_entries, government_schemes, mandi_prices):
   - Select the table
   - Click **"Disable RLS"**

Or run this SQL in the SQL Editor:

```sql
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE farm_diary_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE government_schemes DISABLE ROW LEVEL SECURITY;
ALTER TABLE mandi_prices DISABLE ROW LEVEL SECURITY;
```

---

## Step 5: Set Up Cloudinary (for Image Uploads)

### 5.1 Create Cloudinary Account
1. Go to **[https://cloudinary.com](https://cloudinary.com)**
2. Click **"Sign Up"** and create an account
3. Verify your email

### 5.2 Get Your Cloudinary Credentials
1. After login, go to your **Dashboard**
2. You'll see your **Cloud Name** at the top (save this)
3. Create an **Upload Preset**:
   - Go to **Settings** → **Upload**
   - Click **"Create Upload Preset"**
   - Set **Signing Mode** to **"Unsigned"**
   - Name it `farmer_app_unsigned`
   - Click **"Save"**

---

## Step 6: Configure Your Flutter App

### 6.1 Create `.env` File
In your `farmer_app/` folder, create a file named `.env` (if it doesn't exist):

```bash
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=farmer_app_unsigned
```

**Replace the values with your actual credentials from steps 2 and 5!**

### 6.2 Verify .env is in .gitignore
Open `farmer_app/.gitignore` and ensure `.env` is listed (so you don't commit secrets):

```
.env
```

### 6.3 Load Dependencies
```bash
cd farmer_app
flutter pub get
```

---

## Step 7: Test Connection

### 7.1 Run the App
```bash
flutter run
```

### 7.2 Test Sign Up
1. On the app's sign-in page, click **"Sign Up"**
2. Enter an email and password (6+ characters)
3. Confirm password and click **"Create Account"**
4. If successful, you should be logged in!

### 7.3 Verify in Supabase
1. Go back to your Supabase dashboard
2. Go to **Authentication** → **Users**
3. You should see your new user account listed!

---

## Step 8: Test Creating a Product (Seller Flow)

1. After logging in, navigate to **Seller** section
2. Click **"Add Product"**
3. Fill in product details:
   - Name, description, price, unit, quantity, category
   - Upload an image (should go to Cloudinary)
4. Click **"Add Product"**
5. If successful, you should see a success message

### Verify in Supabase
1. Go to **SQL Editor** → **New Query**
2. Run: `SELECT * FROM products ORDER BY created_at DESC LIMIT 1;`
3. You should see your newly created product!

---

## Troubleshooting

### "SUPABASE_URL not set in environment"
- Ensure `.env` file exists in `farmer_app/` directory
- Run `flutter pub get` to reload dotenv
- Check that values don't have extra spaces

### "Could not find Cloudinary preset"
- Verify the preset name matches exactly (case-sensitive): `farmer_app_unsigned`
- Ensure it's set to **"Unsigned"** mode in Cloudinary settings

### "Authentication error" when signing up
- Check that Supabase project is fully initialized
- Verify SUPABASE_ANON_KEY is correct (not the secret key!)
- Try refreshing the browser and retrying

### Tables not appearing in SQL Editor
- Wait a few seconds and refresh the page
- Check that the SQL executed successfully (look for "Successfully executed")

---

## Next Steps

Once everything is working:
1. ✅ Users can sign up and log in
2. ✅ Sellers can create products (images upload to Cloudinary)
3. ✅ Products appear in Supabase `products` table
4. ⏳ Buyers can view products and create orders
5. ⏳ Orders are saved to Supabase `orders` table

For production, you'll need to:
- Enable RLS policies for security
- Set up email verification
- Migrate any existing Firebase data
- Add environment variables to CI/CD pipeline

---

## Reference Links

- **Supabase Docs**: https://supabase.com/docs
- **Supabase Dashboard**: https://app.supabase.com
- **Cloudinary Docs**: https://cloudinary.com/documentation
- **Cloudinary Dashboard**: https://cloudinary.com/console
