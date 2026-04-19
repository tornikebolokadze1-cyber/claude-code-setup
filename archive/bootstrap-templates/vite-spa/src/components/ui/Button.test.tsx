import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Button } from "./Button";

describe("Button", () => {
  it("renders children", () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole("button", { name: "Click me" })).toBeInTheDocument();
  });

  it("applies variant class", () => {
    render(<Button variant="secondary">Secondary</Button>);
    const btn = screen.getByRole("button");
    expect(btn).toHaveClass("btn--secondary");
  });

  it("applies size class", () => {
    render(<Button size="lg">Large</Button>);
    expect(screen.getByRole("button")).toHaveClass("btn--lg");
  });

  it("calls onClick when clicked", async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    await user.click(screen.getByRole("button"));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it("is disabled when disabled prop is set", () => {
    render(<Button disabled>Disabled</Button>);
    expect(screen.getByRole("button")).toBeDisabled();
  });

  it("is disabled and shows loading indicator when isLoading", () => {
    render(<Button isLoading>Save</Button>);
    const btn = screen.getByRole("button");
    expect(btn).toBeDisabled();
    expect(btn).toHaveAttribute("aria-busy", "true");
  });

  it("does not call onClick when disabled", async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();
    render(
      <Button disabled onClick={handleClick}>
        Noop
      </Button>
    );
    await user.click(screen.getByRole("button"));
    expect(handleClick).not.toHaveBeenCalled();
  });

  it("merges custom className", () => {
    render(<Button className="custom-class">Styled</Button>);
    expect(screen.getByRole("button")).toHaveClass("custom-class");
  });
});
