import { Link } from "react-router";

export default function NotFound() {
  return (
    <div className="page page--centered">
      <h1>404 — Page Not Found</h1>
      <p>The page you are looking for does not exist.</p>
      <Link to="/">Go back home</Link>
    </div>
  );
}
