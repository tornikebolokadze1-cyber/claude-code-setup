import { createBrowserRouter, Outlet, NavLink } from "react-router";
import { lazy, Suspense } from "react";

// Lazy-load route components for code splitting
const Home = lazy(() => import("./routes/Home"));
const About = lazy(() => import("./routes/About"));
const NotFound = lazy(() => import("./routes/NotFound"));

// Root layout — shared across all routes
function RootLayout() {
  return (
    <div className="app">
      <header className="app-header">
        <nav>
          <NavLink to="/" end>
            Home
          </NavLink>
          <NavLink to="/about">About</NavLink>
        </nav>
      </header>
      <main className="app-main">
        <Suspense fallback={<div className="loading">Loading…</div>}>
          <Outlet />
        </Suspense>
      </main>
    </div>
  );
}

export const router = createBrowserRouter([
  {
    path: "/",
    element: <RootLayout />,
    children: [
      { index: true, element: <Home /> },
      { path: "about", element: <About /> },
      { path: "*", element: <NotFound /> },
    ],
  },
]);
