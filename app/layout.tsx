import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL ?? "https://prizmview.app"),
  title: {
    default: "ITK Tracker | Soccer Transfer Prediction Accuracy",
    template: "%s | ITK Tracker",
  },
  description:
    "Tracks the prediction accuracy of soccer transfer journalists and ITK accounts on X, with a public leaderboard and verified historical records.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
