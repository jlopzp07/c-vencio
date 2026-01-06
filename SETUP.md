# Setup Instructions

## 1. Supabase Setup

### Create Table `vehicles`
Run the following SQL in your Supabase SQL Editor:

```sql
create table vehicles (
  id text primary key, -- Using text for UUID string from client
  license_plate text not null,
  brand text not null,
  model text not null,
  year int not null,
  color text not null,
  owner_document_type text not null,
  owner_document_number text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

### Create Table `expenses`
Run the following SQL in your Supabase SQL Editor:

```sql
create table expenses (
  id text primary key,
  vehicle_id text not null references vehicles(id) on delete cascade,
  category text not null,
  amount numeric not null,
  date timestamp with time zone not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```
```

### Row Level Security (RLS)
For development, you might want to disable RLS or add a policy to allow public access.
**Warning**: For production, enable RLS and configure proper policies.

## 2. Environment Variables Setup

### Create `.env` file
Copy the example file and fill in your actual values:

```bash
cp .env.example .env
```

Then edit `.env` with your credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
VERIFIK_API_KEY=your-verifik-api-key-here
```

**Important**: 
- ✅ `.env` is already in `.gitignore` - it will NOT be committed
- ✅ `.env.example` is the template - this IS committed
- ⚠️ Never commit your actual `.env` file with real credentials

### Get Your Credentials

**Supabase**:
1. Go to your Supabase project dashboard
2. Click on Settings → API
3. Copy the `URL` and `anon/public` key

**Verifik API**:
1. Visit [Verifik](https://verifik.co/)
2. Sign up for an account
3. Get your API key from the dashboard
4. This API provides access to RUNT data (SOAT, Tecnicomecánica, vehicle history)

## 3. Run the Application

```bash
flutter pub get
flutter run
```

## API Information

### Verifik RUNT API

The app uses Verifik's RUNT API to query vehicle information in Colombia:

- **Endpoint**: `https://api.verifik.co/v2/co/runt`
- **Method**: POST
- **Authentication**: Bearer token
- **Required Data**:
  - License plate (placa)
  - Owner document type (CC, CE, etc.)
  - Owner document number

**Data Retrieved**:
- ✅ SOAT status and expiration date
- ✅ Tecnicomecánica (RTM) status and expiration
- ✅ Vehicle details (brand, model, color, year)
- ✅ Owner information
- ✅ Insurance history
