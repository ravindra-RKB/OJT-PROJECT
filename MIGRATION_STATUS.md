# Supabase Migration Status & Next Steps

## Current State (December 4, 2025)

### ✅ Completed

1. **Supabase Service (`lib/services/supabase_service.dart`)**
   - ✅ Initialized with dotenv env vars
   - ✅ Provides client, currentUser, auth helpers
   - ✅ Dynamic types to avoid API mismatches

2. **Authentication (`lib/providers/auth_provider.dart`)**
   - ✅ Migrated from Firebase to Supabase
   - ✅ SimpleUser wrapper preserves `.uid` for backward compat
   - ✅ Sign up, sign in, sign out working

3. **Storage (`lib/services/cloudinary_service.dart` + `lib/services/product_service.dart`)**
   - ✅ Image uploads to Cloudinary (web via HTTP multipart, mobile via file path)
   - ✅ Removed Firebase Storage dependency
   - ✅ Product images now hosted on Cloudinary

4. **Products (`lib/services/product_service.dart`)**
   - ✅ `createProductSupabase(...)` — Insert products into Supabase
   - ✅ `Product.fromMap(...)` — Factory for Supabase rows

5. **Orders (`lib/services/order_service.dart` + `lib/models/order.dart`)**
   - ✅ `createOrderSupabase(...)` — Create orders in Supabase
   - ✅ `getOrderByIdSupabase(...)` — Fetch single order
   - ✅ `getBuyerOrdersSupabase(...)` — List buyer's orders
   - ✅ `updateOrderStatusSupabase(...)` — Update order status & quantities
   - ✅ `Order.fromSupabase(...)` — Factory handles Supabase timestamp formats

6. **Database Schema (`SUPABASE_MIGRATION_GUIDE.md`)**
   - ✅ SQL for all tables (products, orders, user_profiles, farm_diary_entries, government_schemes, mandi_prices)
   - ✅ Indexes for performance
   - ✅ Environment setup instructions

---

## ⏳ Remaining Work

### High Priority (Blocks UI / User Workflows)

**ProductService Read/Stream Methods**
- Add `getProductsSupabase()` — Fetch products with optional filters (distance, category)
- Add `streamProductsSupabase()` (or polling) — Real-time marketplace updates
- Update callers in marketplace pages to use Supabase methods
- Status: ~2-3 hours work

**ProfileService Migration**
- Convert all Firestore reads/writes to Supabase
- Update `profile_provider.dart` if needed
- Status: ~1-2 hours work

### Medium Priority (Completes Migration)

**DiaryService, SchemeService, MandiService Migration**
- Similar to orders: add Supabase variants, update service methods
- Status: ~2-3 hours total

**Remove Firebase Packages**
- Delete from `pubspec.yaml`
- Delete `firebase_options.dart`
- Remove platform plugin references
- Update `windows/flutter/generated_plugins.cmake` and similar
- Status: ~1 hour cleanup

### Low Priority (Testing & Optimization)

- Add RLS policies to Supabase tables (if security requirements change)
- Write integration tests for Supabase service methods
- Migrate Firebase data if you have existing users/products
- Status: ~2-3 hours (optional for MVP)

---

## Quick Action Items

1. **Set up Supabase project:**
   - Create account, create project, get URL + Anon Key
   - Run SQL from `SUPABASE_MIGRATION_GUIDE.md`
   - Disable RLS for testing

2. **Configure environment:**
   - Copy `.env.example` → `.env`
   - Fill in `SUPABASE_URL`, `SUPABASE_ANON_KEY`, Cloudinary creds

3. **Test Auth:**
   ```bash
   cd farmer_app
   flutter pub get
   flutter run
   # Sign up / sign in → should work with Supabase
   ```

4. **Test Product Create:**
   - Navigate to seller → add product
   - Should upload image to Cloudinary and save to Supabase

5. **Verify Data:**
   - Check Supabase dashboard: products table should have new rows
   - Check Cloudinary: images should appear

---

## Estimated Total Time

- **Core migration**: Already ~50% done
- **Remaining read/stream methods**: 2-3 hours
- **Other services**: 2-3 hours
- **Cleanup**: 1 hour
- **Testing**: 1-2 hours
- **Total**: ~7-11 hours for full migration

---

## Deployment Checklist (When Ready)

- [ ] All services migrated to Supabase
- [ ] Firebase packages removed from pubspec.yaml
- [ ] Environment vars configured in CI/CD pipeline
- [ ] Tests pass locally: `flutter analyze`, `flutter test`
- [ ] Manual smoke tests on emulator/device
- [ ] Supabase RLS policies configured for production
- [ ] Data migrated from Firebase (if applicable)
- [ ] Rollback plan in place (keep Firebase config accessible temporarily)

---

## Reference Links

- **Supabase Docs**: https://supabase.com/docs
- **Cloudinary Docs**: https://cloudinary.com/documentation
- **Flutter Supabase**: https://pub.dev/packages/supabase_flutter
- **Cloudinary Public**: https://pub.dev/packages/cloudinary_public
