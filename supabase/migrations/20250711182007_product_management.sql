-- Product Management Module Migration
-- Location: supabase/migrations/20250711182007_product_management.sql

-- 1. Create custom types
CREATE TYPE public.product_status AS ENUM ('aktif', 'nonaktif', 'habis');
CREATE TYPE public.unit_type AS ENUM ('pcs', 'kg', 'liter', 'meter', 'box', 'karton', 'lusin');

-- 2. Create user_profiles table (intermediary for auth relationships)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create products table based on spreadsheet header
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku TEXT NOT NULL UNIQUE,
    nama_produk TEXT NOT NULL,
    kode_produk TEXT NOT NULL UNIQUE,
    kategori TEXT NOT NULL,
    sub_kategori TEXT,
    barcode TEXT UNIQUE,
    deskripsi TEXT,
    supplier TEXT,
    unit public.unit_type DEFAULT 'pcs'::public.unit_type,
    harga_satuan DECIMAL(12,2) NOT NULL DEFAULT 0,
    partai INTEGER DEFAULT 0,
    keliling INTEGER DEFAULT 0,
    ecer INTEGER DEFAULT 0,
    tanggal_dibuat TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    keterangan TEXT,
    status public.product_status DEFAULT 'aktif'::public.product_status,
    image_url TEXT,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create categories table for better organization
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_system_category BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create sub_categories table
CREATE TABLE public.sub_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, category_id)
);

-- 6. Create suppliers table
CREATE TABLE public.suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    contact_person TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Create inventory_transactions table for tracking stock movements
CREATE TABLE public.inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('in', 'out', 'adjustment')),
    quantity INTEGER NOT NULL,
    previous_stock INTEGER NOT NULL,
    new_stock INTEGER NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. Create essential indexes
CREATE INDEX idx_products_sku ON public.products(sku);
CREATE INDEX idx_products_barcode ON public.products(barcode);
CREATE INDEX idx_products_kategori ON public.products(kategori);
CREATE INDEX idx_products_nama_produk ON public.products(nama_produk);
CREATE INDEX idx_products_status ON public.products(status);
CREATE INDEX idx_products_created_by ON public.products(created_by);
CREATE INDEX idx_categories_name ON public.categories(name);
CREATE INDEX idx_sub_categories_category_id ON public.sub_categories(category_id);
CREATE INDEX idx_suppliers_name ON public.suppliers(name);
CREATE INDEX idx_inventory_transactions_product_id ON public.inventory_transactions(product_id);
CREATE INDEX idx_inventory_transactions_created_at ON public.inventory_transactions(created_at);

-- 9. Enable RLS for all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sub_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_transactions ENABLE ROW LEVEL SECURITY;

-- 10. Create helper functions for RLS policies
CREATE OR REPLACE FUNCTION public.is_authenticated_user()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT auth.uid() IS NOT NULL
$$;

CREATE OR REPLACE FUNCTION public.owns_product(product_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.products p
    WHERE p.id = product_uuid AND p.created_by = auth.uid()
)
$$;

-- 11. Create RLS policies
-- User profiles policies
CREATE POLICY "users_own_profile"
ON public.user_profiles
FOR ALL
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Products policies - allow all authenticated users to read, only creators to modify
CREATE POLICY "authenticated_users_read_products"
ON public.products
FOR SELECT
TO authenticated
USING (public.is_authenticated_user());

CREATE POLICY "authenticated_users_create_products"
ON public.products
FOR INSERT
TO authenticated
WITH CHECK (public.is_authenticated_user() AND auth.uid() = created_by);

CREATE POLICY "creators_update_products"
ON public.products
FOR UPDATE
TO authenticated
USING (public.owns_product(id))
WITH CHECK (public.owns_product(id));

CREATE POLICY "creators_delete_products"
ON public.products
FOR DELETE
TO authenticated
USING (public.owns_product(id));

-- Categories policies - read for all authenticated users
CREATE POLICY "authenticated_users_read_categories"
ON public.categories
FOR SELECT
TO authenticated
USING (public.is_authenticated_user());

CREATE POLICY "authenticated_users_manage_categories"
ON public.categories
FOR ALL
TO authenticated
USING (public.is_authenticated_user())
WITH CHECK (public.is_authenticated_user());

-- Sub-categories policies
CREATE POLICY "authenticated_users_read_sub_categories"
ON public.sub_categories
FOR SELECT
TO authenticated
USING (public.is_authenticated_user());

CREATE POLICY "authenticated_users_manage_sub_categories"
ON public.sub_categories
FOR ALL
TO authenticated
USING (public.is_authenticated_user())
WITH CHECK (public.is_authenticated_user());

-- Suppliers policies
CREATE POLICY "authenticated_users_read_suppliers"
ON public.suppliers
FOR SELECT
TO authenticated
USING (public.is_authenticated_user());

CREATE POLICY "authenticated_users_manage_suppliers"
ON public.suppliers
FOR ALL
TO authenticated
USING (public.is_authenticated_user())
WITH CHECK (public.is_authenticated_user());

-- Inventory transactions policies
CREATE POLICY "authenticated_users_read_transactions"
ON public.inventory_transactions
FOR SELECT
TO authenticated
USING (public.is_authenticated_user());

CREATE POLICY "authenticated_users_create_transactions"
ON public.inventory_transactions
FOR INSERT
TO authenticated
WITH CHECK (public.is_authenticated_user() AND auth.uid() = created_by);

-- 12. Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$;

-- 13. Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 14. Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 15. Create triggers for updating timestamps
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 16. Insert sample data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    category_electronics UUID := gen_random_uuid();
    category_clothing UUID := gen_random_uuid();
    category_food UUID := gen_random_uuid();
    supplier_samsung UUID := gen_random_uuid();
    supplier_nike UUID := gen_random_uuid();
BEGIN
    -- Create sample auth users
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@stockscan.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@stockscan.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Regular User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert sample categories
    INSERT INTO public.categories (id, name, description, is_system_category) VALUES
        (category_electronics, 'Elektronik', 'Kategori untuk produk elektronik', true),
        (category_clothing, 'Pakaian', 'Kategori untuk produk pakaian', true),
        (category_food, 'Makanan', 'Kategori untuk produk makanan', true);

    -- Insert sample sub-categories
    INSERT INTO public.sub_categories (category_id, name, description) VALUES
        (category_electronics, 'Smartphone', 'Telepon pintar dan aksesoris'),
        (category_electronics, 'Laptop', 'Komputer laptop dan aksesoris'),
        (category_clothing, 'Sepatu', 'Sepatu pria dan wanita'),
        (category_clothing, 'Jaket', 'Jaket dan outerwear'),
        (category_food, 'Minuman', 'Minuman kemasan dan segar');

    -- Insert sample suppliers
    INSERT INTO public.suppliers (id, name, contact_person, phone, email, address) VALUES
        (supplier_samsung, 'Samsung Indonesia', 'Budi Santoso', '+62-21-12345678', 'budi@samsung.co.id', 'Jakarta, Indonesia'),
        (supplier_nike, 'Nike Indonesia', 'Sari Dewi', '+62-21-87654321', 'sari@nike.co.id', 'Bandung, Indonesia');

    -- Insert sample products
    INSERT INTO public.products (
        sku, nama_produk, kode_produk, kategori, sub_kategori, barcode,
        deskripsi, supplier, unit, harga_satuan, partai, keliling, ecer,
        keterangan, status, image_url, created_by
    ) VALUES
        ('SKU-001', 'Samsung Galaxy S24 Ultra', 'SAMS24U', 'Elektronik', 'Smartphone', '8801643740825',
         'Smartphone flagship Samsung dengan kamera 200MP dan S-Pen', 'Samsung Indonesia', 'pcs'::public.unit_type,
         18999000, 50, 25, 0, 'Stok terbatas', 'aktif'::public.product_status,
         'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?fm=jpg&q=60&w=400', admin_uuid),
        
        ('SKU-002', 'Nike Air Max 270', 'NIKEAM270', 'Pakaian', 'Sepatu', '194501234567',
         'Sepatu running Nike dengan teknologi Air Max', 'Nike Indonesia', 'pcs'::public.unit_type,
         2200000, 30, 8, 0, 'Stok menipis', 'aktif'::public.product_status,
         'https://images.unsplash.com/photo-1542291026-7eec264c27ff?fm=jpg&q=60&w=400', admin_uuid),
        
        ('SKU-003', 'MacBook Pro 16 inch', 'APMBP16', 'Elektronik', 'Laptop', '194252056851',
         'Laptop profesional Apple dengan chip M3 Pro', 'Apple Indonesia', 'pcs'::public.unit_type,
         42999000, 20, 12, 0, 'Pre-order tersedia', 'aktif'::public.product_status,
         'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?fm=jpg&q=60&w=400', admin_uuid),
        
        ('SKU-004', 'Levi''s 501 Original Jeans', 'LEVI501', 'Pakaian', 'Celana', '501234567890',
         'Celana jeans klasik Levi''s dengan potongan original', 'Levi''s Indonesia', 'pcs'::public.unit_type,
         1299000, 40, 0, 0, 'Stok habis', 'habis'::public.product_status,
         'https://images.unsplash.com/photo-1542272604-787c3835535d?fm=jpg&q=60&w=400', admin_uuid),
        
        ('SKU-005', 'Sony WH-1000XM5', 'SONYWH1000', 'Elektronik', 'Headphone', '027242920057',
         'Headphone wireless dengan noise cancellation terbaik', 'Sony Indonesia', 'pcs'::public.unit_type,
         5499000, 25, 15, 0, 'Baru diluncurkan', 'aktif'::public.product_status,
         'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?fm=jpg&q=60&w=400', admin_uuid);

    -- Insert sample inventory transactions
    INSERT INTO public.inventory_transactions (
        product_id, transaction_type, quantity, previous_stock, new_stock, notes, created_by
    ) SELECT
        p.id, 'in', 
        CASE p.sku
            WHEN 'SKU-001' THEN 25
            WHEN 'SKU-002' THEN 8
            WHEN 'SKU-003' THEN 12
            WHEN 'SKU-004' THEN 0
            WHEN 'SKU-005' THEN 15
        END,
        0,
        CASE p.sku
            WHEN 'SKU-001' THEN 25
            WHEN 'SKU-002' THEN 8
            WHEN 'SKU-003' THEN 12
            WHEN 'SKU-004' THEN 0
            WHEN 'SKU-005' THEN 15
        END,
        'Initial stock entry',
        admin_uuid
    FROM public.products p;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 17. Create cleanup function for testing
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs to delete
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@stockscan.com';

    -- Delete in dependency order
    DELETE FROM public.inventory_transactions WHERE created_by = ANY(auth_user_ids_to_delete);
    DELETE FROM public.products WHERE created_by = ANY(auth_user_ids_to_delete);
    DELETE FROM public.sub_categories WHERE category_id IN (
        SELECT id FROM public.categories WHERE name IN ('Elektronik', 'Pakaian', 'Makanan')
    );
    DELETE FROM public.categories WHERE name IN ('Elektronik', 'Pakaian', 'Makanan');
    DELETE FROM public.suppliers WHERE name LIKE '%Indonesia';
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;