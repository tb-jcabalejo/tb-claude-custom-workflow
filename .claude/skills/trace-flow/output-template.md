# Trace output template

Write `docs/traces/<slug>.md` with the sections below, in this order. Delete a section only when that layer does not exist, and say why under **Gaps**.

Names such as `OrdersPage` and `fetchOrders` show the shape. They are not symbols in this repo. Copy the structure, not the names.

## Sections

**Title and meta**

- H1: page or action name
- **Entry:** route or action
- **Scope:** `load`, or `load` plus the named actions
- **Roots:** workspace paths actually opened

**Flow**

One mermaid `flowchart TD`. A second chart only for a named action the user included.

**Hops**

| # | Layer | Symbol | Contract | File |
|---|--------|--------|----------|------|
| 1 | Route | symbol | path | file |
| 2 | Client | symbol | `GET /resource` | file |
| 3 | API | symbol or unverified | method and path | file or unverified |
| 4 | Database | table | engine and predicate | `file:line` |

**Process**

One sentence per hop, in call order, from mount through the function that places fields on screen.

**Data**

- Request fields the page sends
- Response fields that show on screen, mapped to the UI label
- Tables or views, with the citation for each relation

**Gaps**

Unverified hops, missing backend repo, or a graph result that disagreed with source.

## Label rules

| Hop | Node label |
|-----|------------|
| Page, hook, service, mapper | `` `symbol` `` |
| HTTP client or route | `` `symbol` `` then `METHOD /path` on the next line (`<br/>`) |
| Transport | `` `apiClient` request `` plus the auth or base-URL fact that matters |
| Database | table or view name, plus `Postgres` or `Snowflake` |

Group nodes with `subgraph` for Page, Client, API, Functions, Database, and Render.

Keep a single chart at or under 25 nodes. If mount fires many calls, branch once per call. Do not drop a call to stay under the cap. Split into a `Load` chart and a `Secondary fetches` chart.

Collapse a hop only when it forwards arguments with no branch, no mapping, and no I/O. List those symbols under the chart as `Collapsed pass-throughs`.

## Shape example

```mermaid
flowchart TD
  subgraph Page
    A["`OrdersPage`"]
    Q1["`useOrdersQuery`"]
    Q2["`useBuyersQuery`"]
  end
  subgraph Client
    A1["`fetchOrders`<br/>GET /orders"]
    A2["`fetchBuyers`<br/>GET /buyers"]
    T["`apiClient` request<br/>Authorization"]
  end
  subgraph API
    H["`list_orders`<br/>GET /orders"]
  end
  subgraph Functions
    S["`OrderService.list`"]
  end
  subgraph Database
    D["`orders`<br/>Postgres"]
  end
  subgraph Render
    R["`orderColumns`"]
  end
  A --> Q1 --> A1 --> T --> H --> S --> D --> R
  A --> Q2 --> A2
```

`fetchBuyers` stops at the client in this example because that backend root was not opened. That hop belongs in **Gaps**, not as a guessed handler.

## Chat reply

Lead with the same mermaid block, then the **Process** sentences, then **Gaps**, then the path `docs/traces/<slug>.md`. Do not repeat the hop table in chat when the file has it.
