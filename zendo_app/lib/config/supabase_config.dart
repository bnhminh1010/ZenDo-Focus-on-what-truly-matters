/// Supabase configuration file
/// Contains project URL and API keys for connecting to Supabase backend
class SupabaseConfig {
  // Supabase project URL
  static const String url = 'https://ewfjqvatkzeyccilxzne.supabase.co';
  
  // Supabase anon public key (safe to use in client-side code)
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3ZmpxdmF0a3pleWNjaWx4em5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NjMxMDEsImV4cCI6MjA3NTQzOTEwMX0.JhSrgxhaT-nfzx6aQuv9MO7qwD5NXhtGJZFtcHBKdeY';
  
  // Note: Never expose service_role key in client-side code
  // Only use anon key for Flutter applications
}