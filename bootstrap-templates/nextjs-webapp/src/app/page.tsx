export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold tracking-tight">
        {{PROJECT_NAME}}
      </h1>
      <p className="mt-4 text-lg text-muted-foreground">
        Next.js 14 + TypeScript + Tailwind + Supabase
      </p>
      <div className="mt-8 flex gap-4">
        <a
          href="/health"
          className="rounded-lg bg-blue-600 px-6 py-3 text-white hover:bg-blue-700 transition-colors"
        >
          Health Check
        </a>
        <a
          href="/login"
          className="rounded-lg border border-gray-300 px-6 py-3 hover:bg-gray-50 transition-colors"
        >
          Login
        </a>
      </div>
    </main>
  );
}
