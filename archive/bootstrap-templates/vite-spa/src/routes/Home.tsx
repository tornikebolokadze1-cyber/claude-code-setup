import { env } from "@/lib/env";
import { Button } from "@/components/ui/Button";

export default function Home() {
  return (
    <div className="page">
      <h1>{env.VITE_APP_TITLE}</h1>
      <p>Welcome to your Vite + React 19 + TypeScript SPA.</p>
      <p>
        Edit <code>src/routes/Home.tsx</code> to get started.
      </p>
      <div className="button-group">
        <Button variant="primary" onClick={() => alert("Primary clicked!")}>
          Primary Action
        </Button>
        <Button variant="secondary" onClick={() => alert("Secondary clicked!")}>
          Secondary Action
        </Button>
      </div>
    </div>
  );
}
