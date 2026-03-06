# Create ASP.NET Core Razor/Blazor Sample Apps

Create 7 ASP.NET Core applications under `./src`, each showcasing a different Razor/Blazor flavor. Every app is standalone with no inter-project dependencies. Each app has its own solution file (`.sln`) in its folder.

- **Target framework:** .NET 10
- **Authentication:** None
- **HTTPS:** Enabled
- **Solution format:** `.slnx` (XML-based solution format)

## Folder Structure

All apps live under `./src`, each in its own folder named after the flavor it demonstrates:

```
src/
├── BlazorStaticServerRendering/
├── BlazorInteractiveServer/
├── BlazorInteractiveWebAssembly/
├── BlazorInteractiveAuto/
├── BlazorStandaloneWebAssembly/
├── RazorPages/
└── MvcWithRazorViews/
```

## App 1: BlazorStaticServerRendering

**What it demonstrates:** Blazor with static server-side rendering (SSR) only — no interactive components. All HTML is rendered on the server and sent to the browser as static content. This is the simplest Blazor model with no WebSocket or WebAssembly overhead.

```shell
mkdir src/BlazorStaticServerRendering
cd src/BlazorStaticServerRendering
dotnet new blazor --interactivity None --name BlazorStaticServerRendering
dotnet new sln --format slnx --name BlazorStaticServerRendering
dotnet sln add BlazorStaticServerRendering/BlazorStaticServerRendering.csproj
cd ../..
```

## App 2: BlazorInteractiveServer

**What it demonstrates:** Blazor with interactive server-side rendering. UI updates are handled over a real-time SignalR (WebSocket) connection. The `--all-interactive` flag makes every page interactive by default (render mode applied at the top level).

```shell
mkdir src/BlazorInteractiveServer
cd src/BlazorInteractiveServer
dotnet new blazor --interactivity Server --all-interactive --name BlazorInteractiveServer
dotnet new sln --format slnx --name BlazorInteractiveServer
dotnet sln add BlazorInteractiveServer/BlazorInteractiveServer.csproj
cd ../..
```

## App 3: BlazorInteractiveWebAssembly

**What it demonstrates:** Blazor with interactive WebAssembly rendering. The .NET runtime and app code are downloaded to the browser and executed client-side via WebAssembly. The `--all-interactive` flag makes every page interactive by default. This template generates a multi-project structure: a server project and a `.Client` project.

> **Note:** This multi-project template generates its own `.sln` file. Run `dotnet new blazor` from the `src/` directory (not from inside the project folder) to avoid double-nesting. Then replace the generated `.sln` with a `.slnx`.

```shell
cd src
dotnet new blazor --interactivity WebAssembly --all-interactive --name BlazorInteractiveWebAssembly
cd BlazorInteractiveWebAssembly
rm BlazorInteractiveWebAssembly.sln
dotnet new sln --format slnx --name BlazorInteractiveWebAssembly
dotnet sln add BlazorInteractiveWebAssembly/BlazorInteractiveWebAssembly.csproj
dotnet sln add BlazorInteractiveWebAssembly.Client/BlazorInteractiveWebAssembly.Client.csproj
cd ../..
```

## App 4: BlazorInteractiveAuto

**What it demonstrates:** Blazor with Auto interactive rendering. This is the hybrid mode — it uses interactive Server rendering (SignalR) on first load while WebAssembly assets download in the background, then switches to WebAssembly for subsequent visits. The `--all-interactive` flag makes every page interactive by default. This template generates a multi-project structure: a server project and a `.Client` project.

> **Note:** This multi-project template generates its own `.sln` file. Run `dotnet new blazor` from the `src/` directory (not from inside the project folder) to avoid double-nesting. Then replace the generated `.sln` with a `.slnx`.

```shell
cd src
dotnet new blazor --interactivity Auto --all-interactive --name BlazorInteractiveAuto
cd BlazorInteractiveAuto
rm BlazorInteractiveAuto.sln
dotnet new sln --format slnx --name BlazorInteractiveAuto
dotnet sln add BlazorInteractiveAuto/BlazorInteractiveAuto.csproj
dotnet sln add BlazorInteractiveAuto.Client/BlazorInteractiveAuto.Client.csproj
cd ../..
```

## App 5: BlazorStandaloneWebAssembly

**What it demonstrates:** A standalone Blazor WebAssembly app that runs entirely in the browser — no server project. This is a pure client-side single-page application (SPA) using the `blazorwasm` template. It can be hosted as static files on any web server or CDN.

```shell
mkdir src/BlazorStandaloneWebAssembly
cd src/BlazorStandaloneWebAssembly
dotnet new blazorwasm --name BlazorStandaloneWebAssembly
dotnet new sln --format slnx --name BlazorStandaloneWebAssembly
dotnet sln add BlazorStandaloneWebAssembly/BlazorStandaloneWebAssembly.csproj
cd ../..
```

## App 6: RazorPages

**What it demonstrates:** ASP.NET Core Razor Pages — a page-focused server-side web framework. Each page is a `.cshtml` file paired with a `PageModel` class. This is the traditional server-rendered approach without Blazor components, ideal for form-heavy or content-driven apps.

```shell
mkdir src/RazorPages
cd src/RazorPages
dotnet new webapp --name RazorPages
dotnet new sln --format slnx --name RazorPages
dotnet sln add RazorPages/RazorPages.csproj
cd ../..
```

## App 7: MvcWithRazorViews

**What it demonstrates:** ASP.NET Core MVC with Razor Views — the classic Model-View-Controller pattern. Controllers handle requests, models carry data, and `.cshtml` Razor views render the HTML. This is the most established ASP.NET pattern for server-rendered web apps.

```shell
mkdir src/MvcWithRazorViews
cd src/MvcWithRazorViews
dotnet new mvc --name MvcWithRazorViews
dotnet new sln --format slnx --name MvcWithRazorViews
dotnet sln add MvcWithRazorViews/MvcWithRazorViews.csproj
cd ../..
```

## Verification

After creating all apps, verify each one builds successfully:

```shell
dotnet build src/BlazorStaticServerRendering/BlazorStaticServerRendering.slnx
dotnet build src/BlazorInteractiveServer/BlazorInteractiveServer.slnx
dotnet build src/BlazorInteractiveWebAssembly/BlazorInteractiveWebAssembly.slnx
dotnet build src/BlazorInteractiveAuto/BlazorInteractiveAuto.slnx
dotnet build src/BlazorStandaloneWebAssembly/BlazorStandaloneWebAssembly.slnx
dotnet build src/RazorPages/RazorPages.slnx
dotnet build src/MvcWithRazorViews/MvcWithRazorViews.slnx
```
