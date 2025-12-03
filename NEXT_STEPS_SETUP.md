# Next Steps - Connect Your App to Supabase

You've created your Supabase project! Now let's complete the setup. Follow these steps in order.

---

## Step 1: Get Your Supabase Credentials

### 1.1 Find Project URL & Anon Key
1. Go to your **Supabase Dashboard**: https://app.supabase.com
2. Select your project
3. Click **Settings** (gear icon, bottom left)
4. Click **API** from the left sidebar
5. You'll see:
   - **Project URL** (looks like `https://xxxxxxxxxxxx.supabase.co`)
   - **Anon/Public Key** (long string starting with `eyJ...`)

### 1.2 Save These Values
Copy both values somewhere safe (you'll need them in a moment)

---

## Step 2: Create Supabase Tables (SQL)

### 2.1 Open SQL Editor
1. In your Supabase project, click **SQL Editor** (left sidebar)
2. Click **New Query** button

### 2.2 Copy the SQL
Run the following SQL in your SQL Editor:

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

### 2.3 Run the Query
- Click **Run** button (or press `Ctrl+Enter`)
- You should see: "Successfully executed X statements"

---

## Step 3: Disable Row Level Security (RLS) - For Testing Only

### 3.1 Run This SQL
In the same SQL Editor, run:

```sql
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE farm_diary_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE government_schemes DISABLE ROW LEVEL SECURITY;
ALTER TABLE mandi_prices DISABLE ROW LEVEL SECURITY;
```

⚠️ **WARNING**: RLS disabled = Anyone can read/write all data. This is ONLY for testing/development!

---

## Step 4: Set Up Cloudinary

### 4.1 Create Cloudinary Account
1. Go to **https://cloudinary.com**
2. Click **Sign Up**
3. Create an account (use email or GitHub)
4. Verify email

### 4.2 Get Your Cloud Name
1. After login, go to **Dashboard**
2. At the top, you'll see your **Cloud Name** (like `dsdhf7342sd`)
3. **Save this value**

### 4.3 Create Upload Preset
1. Go to **Settings** (gear icon, top right)
2. Click **Upload** tab
3. Scroll to **Upload presets** section
4. Click **Add upload preset**
5. Configure:
   - **Name**: `farmer_app_unsigned`
   - **Signing Mode**: Select **Unsigned**
   - Click **Save**

### 4.4 Verify It Worked
- Go back to Upload section
- You should see `farmer_app_unsigned` in your presets list

---

## Step 5: Update Your `.env` File

### 5.1 Open `.env` File
In your `farmer_app/` folder, open `.env` file (or create it if it doesn't exist)

### 5.2 Fill in Your Credentials
Replace the placeholder values with your actual credentials:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
CLOUDINARY_CLOUD_NAME=your-actual-cloud-name
CLOUDINARY_UPLOAD_PRESET=farmer_app_unsigned
```

**Example (with real values):**
```env
SUPABASE_URL=https://abcdef123456.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZjEyMzQ1NiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzAxMDAwMDAwLCJleHAiOjIwMDAwMDAwMDB9.abc123def456
CLOUDINARY_CLOUD_NAME=my_cloud_123
CLOUDINARY_UPLOAD_PRESET=farmer_app_unsigned
```

### 5.3 Save the File
Make sure `.env` is saved in the `farmer_app/` directory

### 5.4 Verify .env is in .gitignore
Open `farmer_app/.gitignore` and make sure it contains `.env`:

```
.env
```

This ensures your secrets don't get committed to git!

---

## Step 6: Update Flutter Dependencies

### 6.1 Get Dependencies
Open terminal in `farmer_app/` and run:

```bash
flutter pub get
```

This ensures all packages are downloaded with your `.env` ready.

---

## Step 7: Test the Connection

### 7.1 Run the App
```bash
flutter run
```

### 7.2 Test Sign Up
1. On the sign-in screen, click **"Sign Up"**
2. Enter:
   - **Email**: `test@example.com` (or any email)
   - **Password**: `Password123` (6+ characters)
   - **Confirm**: `Password123`
3. Click **"Create Account"**
4. If it works, you should be logged in and see the home page!

### 7.3 Verify in Supabase
1. Go to your Supabase dashboard
2. Click **Authentication** (left sidebar)
3. Click **Users** tab
4. You should see your test account in the list!

### 7.4 If It Fails
- Check `.env` file has correct values (no extra spaces)
- Check that SUPABASE_ANON_KEY is the **Anon/Public Key**, NOT the secret key
- Run `flutter pub get` again
- Check that Supabase tables were created (go to SQL Editor → Table Editor)

---

## Step 8: Test Seller Flow (Create Product)

### 8.1 Log In as Seller
1. After signing up, you're logged in
2. Look for **Seller** option or **Add Product** button

### 8.2 Create a Product
1. Click **Add Product**
2. Fill in:
   - **Product Name**: `Tomatoes`
   - **Description**: `Fresh red tomatoes`
   - **Price**: `50`
   - **Unit**: `kg`
   - **Quantity**: `100`
   - **Category**: `Vegetables`
   - **Pick an Image**: Select from your phone/computer
3. Click **Add Product**
4. If successful, you should see: "✓ Product added successfully!"

### 8.3 Verify in Supabase
1. Go to Supabase dashboard
2. Click **SQL Editor** → **New Query**
3. Run: `SELECT * FROM products ORDER BY created_at DESC LIMIT 1;`
4. You should see your product in the results!

### 8.4 Verify Image Upload to Cloudinary
1. Go to **https://cloudinary.com/console**
2. Go to **Media Library**
3. You should see your uploaded image!

---

## 🎉 Success Checklist

- ✅ Supabase project created
- ✅ Tables created in Supabase
- ✅ Cloudinary account created
- ✅ `.env` file configured with credentials
- ✅ App runs without errors
- ✅ Can sign up and log in
- ✅ User appears in Supabase Auth
- ✅ Can create products
- ✅ Products appear in Supabase
- ✅ Images upload to Cloudinary

---

## Troubleshooting

### "Cannot read property 'SUPABASE_URL'"
- Ensure `.env` file is in `farmer_app/` folder
- Run `flutter pub get` to reload
- Check for typos in `.env`

### "Unauthorized: Invalid token with JWT error"
- Check SUPABASE_ANON_KEY value (should be the public/anon key, not secret)
- Regenerate key in Supabase if needed

### "Failed to create product"
- Check that product table exists in Supabase
- Check RLS is disabled for testing
- Verify Cloudinary credentials

### Image not uploading
- Verify Cloudinary Cloud Name is correct
- Check preset `farmer_app_unsigned` exists and is set to Unsigned
- Check file size (should be < 10MB)

---

## Next Steps (After Everything Works)

1. Test creating multiple products
2. Test buyer flow: view products, create orders
3. Test order status updates
4. (Optional) Migrate other services (profile, diary, etc.)
5. (Optional) Remove Firebase packages when ready

---

## Need Help?

If something doesn't work:
1. Check the logs in VS Code (Debug Console)
2. Verify credentials in `.env`
3. Check Supabase/Cloudinary dashboards for errors
4. Try running `flutter clean` then `flutter pub get` and `flutter run` again

Good luck! 🚀
