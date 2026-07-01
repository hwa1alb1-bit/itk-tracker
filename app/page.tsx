import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Most Accurate Soccer Transfer Journalists",
  description:
    "ITK Tracker is under construction. We track the prediction accuracy of soccer transfer journalists on X and publish a public leaderboard.",
};

export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 p-8 text-center">
      <h1 className="text-3xl font-bold">Most Accurate Soccer Transfer Journalists</h1>
      <p className="max-w-xl text-base text-neutral-500">
        ITK Tracker is under construction. We track the prediction accuracy of
        soccer transfer journalists and ITK accounts on X, and publish a
        public leaderboard with verified historical records.
      </p>
    </main>
  );
}
