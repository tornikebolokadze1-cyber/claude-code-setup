/**
 * Supabase database types
 * Generate with: npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/types/database.ts
 */
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      // Add your tables here after running supabase gen types
      // Example:
      // profiles: {
      //   Row: { id: string; email: string; created_at: string };
      //   Insert: { id: string; email: string; created_at?: string };
      //   Update: { id?: string; email?: string; created_at?: string };
      // };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
  };
}
