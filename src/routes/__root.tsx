import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  Outlet,
  Link,
  createRootRouteWithContext,
  useRouter,
  HeadContent,
  Scripts,
} from "@tanstack/react-router";

import appCss from "../styles.css?url";
import { Compass, Wordmark } from "@/components/Compass";
import { ThemeToggle } from "@/components/ThemeToggle";

function NotFoundComponent() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-7xl font-bold text-foreground">404</h1>
        <h2 className="mt-4 text-xl font-semibold text-foreground">Page not found</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <div className="mt-6">
          <Link
            to="/"
            className="inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Go home
          </Link>
        </div>
      </div>
    </div>
  );
}

function ErrorComponent({ error, reset }: { error: Error; reset: () => void }) {
  console.error(error);
  const router = useRouter();

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">
          This page didn't load
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Something went wrong on our end. You can try refreshing or head back home.
        </p>
        <div className="mt-6 flex flex-wrap justify-center gap-2">
          <button
            onClick={() => {
              router.invalidate();
              reset();
            }}
            className="inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Try again
          </button>
          <a
            href="/"
            className="inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Go home
          </a>
        </div>
      </div>
    </div>
  );
}

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "CompassEats — the world's best restaurants & bars, wherever you are" },
      { name: "description", content: "Type any city. CompassEats points you to its best restaurants and cocktail bars — ranked by the guides that matter: Michelin, World's 50 Best, and more." },
      { name: "author", content: "CompassEats" },
      { property: "og:title", content: "CompassEats — the world's best, wherever you are" },
      { property: "og:description", content: "The finest restaurants and cocktail bars in any city on earth, charted from the guides that matter." },
      { property: "og:type", content: "website" },
      { property: "og:url", content: "https://www.compasseats.com" },
      { property: "og:image", content: "https://www.compasseats.com/og-image.jpg" },
      { name: "twitter:card", content: "summary_large_image" },
      { name: "twitter:title", content: "CompassEats — the world's best, wherever you are" },
      { name: "twitter:description", content: "The finest restaurants and cocktail bars in any city on earth." },
      { name: "twitter:image", content: "https://www.compasseats.com/og-image.jpg" },
    ],
    links: [
      { rel: "stylesheet", href: appCss },
      { rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300..600;1,9..144,300..600&family=Hanken+Grotesk:wght@300;400;500;600;700&display=swap" },
      { rel: "icon", type: "image/png", href: "/favicon.png" },
    ],
  }),
  shellComponent: RootShell,
  component: RootComponent,
  notFoundComponent: NotFoundComponent,
  errorComponent: ErrorComponent,
});

function RootShell({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html:
              "(function(){try{var t=localStorage.getItem('theme');var d=document.documentElement;if(t==='light'){d.classList.remove('dark')}else{d.classList.add('dark')}}catch(e){}})()",
          }}
        />
        <HeadContent />
      </head>
      <body>
        {children}
        <Scripts />
      </body>
    </html>
  );
}

function RootComponent() {
  const { queryClient } = Route.useRouteContext();
  return (
    <QueryClientProvider client={queryClient}>
      <header className="sticky top-0 z-20 border-b border-border bg-background/70 backdrop-blur-md">
        <div className="mx-auto flex h-[70px] max-w-5xl items-center justify-between px-6">
          <Link to="/" className="flex items-center gap-2.5 no-underline">
            <Compass size={30} />
            <Wordmark />
          </Link>
          <ThemeToggle />
        </div>
      </header>

      <Outlet />

      <footer className="mt-20 border-t border-border py-16 text-center">
        <div className="mx-auto flex flex-col items-center gap-4">
          <Compass size={44} />
          <Wordmark className="!text-2xl" />
          <p className="text-xs font-medium uppercase tracking-[0.3em] text-accent-strong">compasseats.com</p>
          <p className="text-sm text-muted-foreground">The world's best, wherever you are.</p>
        </div>
      </footer>
    </QueryClientProvider>
  );
}
