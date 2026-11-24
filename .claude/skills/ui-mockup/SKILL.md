---
name: ui-mockup
description: Generate a high-fidelity HTML mockup for planned UI changes when no design exists. Used by /feature-plan and /apply-ticket in PLAN. The mockup is the visual contract for frontend-architect and qa-tester.
---

# UI Mockup (Ticketboat)

## When to generate

1. The plan has Frontend tasks that change what users see.
2. No design source exists. Check, in order:
   - Figma, Zeplin, or image links in the request or ticket description.
   - Linear images (`extract_images` on the description markdown) and design attachments on the issue.
   - Screenshots the user attached in this session.
   - An existing `docs/plans/mockups/<slug>.html`.

A design exists → do not generate. Put the link or attachment name in **Design reference**.
No visual change (data, performance, refactor) → skip. Write "No visual change" in **Design reference**.

## Ground it in the real page

- Read the current component(s) for the target route from File changes (graph-first, per `graphify.md`).
- Reproduce the existing page faithfully: title, breadcrumbs, filters, table columns, buttons, copy.
- Draw only the new or changed parts, from the AC. Do not redesign untouched areas or invent features.
- Use the Ant Design components and props the page already uses (for example `Table` columns, `Pagination` `pageSize`, `Form` layout).

## Build

- One self-contained file: `docs/plans/mockups/<slug>.html`. PLAN mode allows it (`docs/plans/**`). No installs, no build step.
- Load scripts from `cdn.jsdelivr.net/npm` at **exact** versions resolved from the target repo's lockfile (`bun.lock`, `pnpm-lock.yaml`, or `package-lock.json`); fall back to the `package.json` floor (for example `antd ^5.27.4` → `5.27.4`). React 19 has no UMD build; use `react@18.3.1` for the mockup in that case.
- Inline mock data with realistic shapes and fake values. No real customer data or PII.
- Render every state the AC name (default, loading, empty, error, boundaries such as page size + 1, permission variants) behind a "Mockup state" `Segmented` switcher.
- Put `data-ac="AC-n"` on each element an AC governs. A "Show AC tags" switch outlines them with a badge.
- Desktop first, 1440 wide. Add a narrow state only when an AC mentions responsiveness.

### Skeleton

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Mockup: <feature></title>
  <!-- Plan: docs/plans/<slug>.md | AC: AC-1..AC-n | Generated mockup, no supplied design | <YYYY-MM-DD> -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/antd@<ver>/dist/reset.css" />
  <script src="https://cdn.jsdelivr.net/npm/react@<ver>/umd/react.production.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/react-dom@<ver>/umd/react-dom.production.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/dayjs@<ver>/dayjs.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/antd@<ver>/dist/antd.min.js"></script>
  <!-- Only if icons appear: https://cdn.jsdelivr.net/npm/@ant-design/icons@<ver>/dist/index.umd.min.js (global: icons) -->
  <script src="https://cdn.jsdelivr.net/npm/@babel/standalone@7.24.0/babel.min.js"></script>
  <style>
    body { margin: 0; background: #f5f5f5; }
    .show-ac [data-ac] { outline: 2px dashed #fa8c16; outline-offset: 2px; position: relative; }
    .show-ac [data-ac]::after { content: attr(data-ac); position: absolute; top: -10px; right: -6px;
      background: #fa8c16; color: #fff; font: 600 10px/16px sans-serif; padding: 0 4px; border-radius: 3px; }
  </style>
</head>
<body>
  <div id="root"></div>
  <script type="text/babel">
    const { ConfigProvider, Segmented, Switch, Space } = antd;
    const STATES = ["Default", "Empty", "Error"]; // only the states the AC name

    function Page({ state }) {
      // Existing page shell copied from the real component; changed parts per AC, tagged with data-ac.
      return null;
    }

    function App() {
      const [state, setState] = React.useState(STATES[0]);
      const [showAc, setShowAc] = React.useState(false);
      return (
        <ConfigProvider>
          <Space style={{ padding: 12, background: "#fff", width: "100%", borderBottom: "1px solid #eee" }}>
            <strong>Mockup state</strong>
            <Segmented options={STATES} value={state} onChange={setState} />
            <Switch checked={showAc} onChange={setShowAc} /> Show AC tags
          </Space>
          <div className={showAc ? "show-ac" : ""} style={{ padding: 24 }}>
            <Page state={state} />
          </div>
        </ConfigProvider>
      );
    }

    ReactDOM.createRoot(document.getElementById("root")).render(<App />);
  </script>
</body>
</html>
```

## Plan updates

- **Design reference:** `Source: Generated mockup` · path · states covered · AC mapped.
- **Frontend tasks:** "Match `docs/plans/mockups/<slug>.html` for layout, copy, and states; the AC win on conflict."
- **Manual QA:** name the mockup state each case is graded against.
- Reply to the user with the absolute mockup path. It is the visual contract; they should open it before `/project-manager`.

## Done when

- [ ] Every AC that changes the UI maps to at least one `data-ac` element or state.
- [ ] Untouched parts match the current page; no invented features.
- [ ] Versions are exact; no unpinned CDN URLs.
- [ ] No real customer data.
