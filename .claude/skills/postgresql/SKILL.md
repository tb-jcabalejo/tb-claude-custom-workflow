---
name: postgresql
description: Apply PostgreSQL best practices for schema design, indexing, transactions, vector search (pgvector), and RAG pipelines. Use when designing schemas, writing queries, optimizing performance, implementing semantic search, or building RAG applications with PostgreSQL. Use with database-expert for query optimization and DBA-level tuning.
---

# PostgreSQL

## Quick Reference

### Schema Organization
- Use one database with multiple named schemas; avoid multiple databases
- Create application-specific schemas; avoid relying on `public`
- Use `GRANT` for schema-level permissions

### Data Types
- Prefer `TEXT` over `VARCHAR(n)` unless length constraints matter
- Use `UUID` for primary keys when distributed generation is needed
- Use `JSONB` for semi-structured data; `JSON` only when you need exact whitespace
- Use `TIMESTAMPTZ` for timestamps (stores UTC, displays in session timezone)

### Transactions
- Wrap related operations in `BEGIN` / `COMMIT`; use `SAVEPOINT` for nested logic
- Keep transactions short; avoid long-running work inside a transaction
- Use `SET TRANSACTION ISOLATION LEVEL` when needed (e.g. `REPEATABLE READ` for consistency)

---

## Index Types and When to Use

| Type | Use Case | Syntax |
|------|----------|--------|
| **B-tree** (default) | Equality, range, sort, `LIKE 'prefix%'` | `CREATE INDEX ON t (col)` |
| **GIN** | `@>`, `?`, `?&`, `?|` on arrays/JSONB; full-text search | `CREATE INDEX ON t USING GIN (col)` |
| **GiST** | Geometric types, full-text, `tsvector`; extensible | `CREATE INDEX ON t USING GiST (col)` |
| **BRIN** | Very large tables with natural order (time, sequence) | `CREATE INDEX ON t USING BRIN (col)` |
| **Hash** | Equality only; rarely needed over B-tree | `CREATE INDEX ON t USING HASH (col)` |

### Index Rules

1. **Index columns used in WHERE, JOIN, ORDER BY**—avoid indexing rarely filtered columns
2. **Composite indexes**: order matters; put equality columns before range columns
   ```sql
   -- Good for WHERE a = ? AND b > ?
   CREATE INDEX ON t (a, b);
   ```
3. **Partial indexes** for filtered subsets:
   ```sql
   CREATE INDEX ON orders (user_id) WHERE status = 'pending';
   ```
4. **Expression indexes** when querying transformed values:
   ```sql
   CREATE INDEX ON users (LOWER(email));
   ```
5. **Avoid over-indexing**: each index adds write cost; measure before adding

### GIN vs GiST for Full-Text
- **GIN**: better query speed, slower updates; prefer for read-heavy
- **GiST**: faster updates, smaller index; prefer for write-heavy or when index size matters

---

## Vector Search (pgvector)

Enable: `CREATE EXTENSION vector;`

### Distance Operators
| Operator | Distance | Operator Class | Typical Use |
|----------|----------|----------------|-------------|
| `<->` | L2 (Euclidean) | `vector_l2_ops` | Raw embeddings |
| `<=>` | Cosine | `vector_cosine_ops` | Normalized embeddings (common) |
| `<#>` | Negative inner product | `vector_ip_ops` | When similarity = dot product |

### Index Types

**HNSW** (preferred for most cases):
- Better recall and robustness to data changes
- Tune `m` (connections per layer) and `ef_construction` (build quality)

```sql
CREATE INDEX ON embeddings USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);
```

**IVFFlat**:
- Faster build, smaller index; good for static or append-heavy data
- Requires `lists` ≥ rows/1000; tune `lists` and `probes` at query time

```sql
CREATE INDEX ON embeddings USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
-- At query time: SET ivfflat.probes = 10;
```

### Query Pattern
```sql
SELECT id, content, embedding <=> $1 AS distance
FROM embeddings
ORDER BY embedding <=> $1
LIMIT 10;
```

---

## RAG with PostgreSQL

### Table Schema
```sql
CREATE TABLE document_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL,
  chunk_index INT NOT NULL,
  content TEXT NOT NULL,
  embedding vector(1536),  -- match embedding model dimensions
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (document_id, chunk_index)
);

CREATE INDEX ON document_chunks USING hnsw (embedding vector_cosine_ops);
CREATE INDEX ON document_chunks (document_id);
```

### Chunking Guidelines
- Chunk size: 256–512 tokens typical; tune for recall vs context
- Overlap: 10–20% between chunks to preserve context at boundaries
- Store `chunk_index` and `document_id` for ordering and deduplication

### RAG Query Flow
1. Embed the user query with the same model used for chunks
2. Run vector similarity search (e.g. top-k with `<=>` or `<->`)
3. Optionally combine with keyword/full-text (hybrid search)
4. Pass retrieved chunks to the LLM as context

---

## Security and Performance

### Security
- Use parameterized queries or prepared statements; never concatenate user input into SQL
- Principle of least privilege: create roles with minimal `GRANT`s
- Use `SECURITY DEFINER` functions sparingly; audit carefully

### Performance
- Use `EXPLAIN (ANALYZE, BUFFERS)` to diagnose slow queries
- Prefer `EXISTS` over `IN` for subqueries when checking existence
- Use `UNION ALL` instead of `UNION` when duplicates are impossible
- Consider connection pooling (PgBouncer, pgpool, asyncpg pool) for high concurrency

### Migrations
- Add indexes `CONCURRENTLY` in production to avoid locking:
  ```sql
  CREATE INDEX CONCURRENTLY idx_name ON table (column);
  ```
- Test rollback paths; keep migrations reversible when possible
