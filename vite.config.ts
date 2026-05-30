import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import {defineConfig} from 'vite';

export default defineConfig(() => {
  return {
    plugins: [react(), tailwindcss()],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, '.'),
      },
    },
    define: {
      __VITE_SUPABASE_URL__: JSON.stringify(process.env.https://uvzczyqhkeoruqrnznrv.supabase.co || process.env.SUPABASE_URL || ''),
      __VITE_SUPABASE_ANON_KEY__: JSON.stringify(process.env.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2emN6eXFoa2VvcnVxcm56bnJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5NzEyMzMsImV4cCI6MjA5NTU0NzIzM30.VPLiy1tcsZCOARIfHDI-8hPjw98_YSwvxZoZ5Ip-hvU || process.env.SUPABASE_ANON_KEY || ''),
    },
    server: {
      // HMR is disabled in AI Studio via DISABLE_HMR env var.
      // Do not modifyâfile watching is disabled to prevent flickering during agent edits.
      hmr: process.env.DISABLE_HMR !== 'true',
      // Disable file watching when DISABLE_HMR is true to save CPU during agent edits.
      watch: process.env.DISABLE_HMR === 'true' ? null : {},
    },
  };
});
