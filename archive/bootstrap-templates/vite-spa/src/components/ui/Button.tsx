import type { ButtonHTMLAttributes } from "react";

export type ButtonVariant = "primary" | "secondary" | "danger";
export type ButtonSize = "sm" | "md" | "lg";

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
}

/**
 * Generic button component with variant and size props.
 * Extend this with your design system tokens / CSS-in-JS.
 */
export function Button({
  variant = "primary",
  size = "md",
  isLoading = false,
  disabled,
  children,
  className = "",
  ...rest
}: ButtonProps) {
  const classes = [
    "btn",
    `btn--${variant}`,
    `btn--${size}`,
    isLoading ? "btn--loading" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <button
      className={classes}
      disabled={disabled ?? isLoading}
      aria-busy={isLoading}
      {...rest}
    >
      {isLoading ? <span aria-hidden="true">…</span> : children}
    </button>
  );
}
