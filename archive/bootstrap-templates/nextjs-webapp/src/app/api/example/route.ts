import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export async function GET() {
  return NextResponse.json({
    message: "Hello from the API",
    timestamp: new Date().toISOString(),
  });
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    return NextResponse.json(
      {
        message: "Data received",
        data: body,
      },
      { status: 201 }
    );
  } catch {
    return NextResponse.json(
      { error: "Invalid JSON body" },
      { status: 400 }
    );
  }
}
