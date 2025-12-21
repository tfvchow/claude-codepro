## MCP Tools - Core Workflow Integration

**Rule:** Query memory first, verify with diagnostics, store learnings last

### Exa - Web Search & Code Context (PREFERRED)

**ALWAYS use Exa instead of Claude Code's built-in WebFetch and WebSearch tools.** Exa returns higher quality, LLM-optimized content with better code examples.

| Task | Use This | NOT This |
|------|----------|----------|
| Code examples, library docs | `get_code_context_exa()` | ~~WebSearch/WebFetch~~ |
| General web search | `web_search_exa()` | ~~WebSearch~~ |
| Fetch specific URL | `crawling_exa()` | ~~WebFetch~~ |

**Examples:**
```
get_code_context_exa("pytest fixtures with database setup")
web_search_exa("Python asyncio error handling patterns")
crawling_exa("https://docs.python.org/3/library/asyncio.html")
```

### Cipher - Project Memory

**Tool:** `mcp_cipher_ask_cipher`

**Query existing knowledge:**
```
"How did we implement authentication?"
"What pattern did we use for error handling?"
"Why did we choose library X over Y?"
```

**Store new learnings:**
```
"Store: Fixed race condition in user service using mutex locks"
"Store: API rate limit is 100 req/min, implemented exponential backoff"
"Store: Database migration pattern: create migration → test locally → review → deploy"
```

**When to use:**
- Start of every task: Query for relevant past decisions
- End of every task: Store what you learned
- Before implementing: Check if similar problem was solved
- After debugging: Document the solution for future reference

### Claude Context - Semantic Code Search

**Tools:**
- `mcp_claude-context_index_codebase` - Index repository for search
- `mcp_claude-context_search_code` - Find code patterns semantically
- `mcp_claude-context_get_indexing_status` - Check if index is ready

**Search patterns:**
```
"authentication middleware implementation"
"error handling in API routes"
"database connection pooling"
"test fixtures for user model"
```

**When to use:**
- Finding existing implementations to follow patterns
- Locating where specific functionality lives
- Understanding how features are structured
- Before writing new code: Search for similar existing code

**Workflow:**
1. Check indexing status first
2. If not indexed, index the codebase
3. Search for relevant patterns
4. Review results to understand existing approaches

### IDE - Diagnostics and Execution

**Tools:**
- `mcp_ide_getDiagnostics` - Get errors, warnings, and type issues
- `mcp_ide_executeCode` - Run code in Jupyter kernel (notebooks only)

**Mandatory usage:**
- **Before starting work:** Check existing diagnostics to understand current state
- **After every file change:** Verify no new errors introduced
- **Before marking complete:** Confirm clean diagnostics

**Never skip diagnostics.** Passing tests don't guarantee no type errors or linting issues.

### MCP Funnel - Tool Discovery

**Tools:**
- `mcp_mcp-funnel_discover_tools_by_words` - Find tools by keywords
- `mcp_mcp-funnel_get_tool_schema` - Get tool parameters
- `mcp_mcp-funnel_bridge_tool_request` - Execute discovered tools

**When to use:**
- Need specialized functionality not in core tools
- Exploring available MCP servers
- Extending capabilities for specific tasks

**Pattern:**
1. Discover tools: `discover_tools_by_words("database migration")`
2. Get schema: `get_tool_schema("discovered_tool_name")`
3. Execute: `bridge_tool_request("tool_name", {args})`

Use sparingly - core tools handle most needs.

## Mandatory Workflow Patterns

### Task Start Sequence

1. **Check diagnostics:** `getDiagnostics()` - Understand current state
2. **Query memory:** `ask_cipher("How did we handle X?")` - Learn from past
3. **Search codebase:** `search_code(path, "relevant pattern")` - Find examples
4. **Search docs if needed:** `web_search_exa("library feature")` or `get_code_context_exa("code pattern")` - External knowledge

### Task End Sequence

1. **Verify diagnostics:** `getDiagnostics()` - Confirm no new errors
2. **Store learnings:** `ask_cipher("Store: [what you learned]")` - Document for future

### When Stuck

1. Query Cipher for past solutions to similar problems
2. Search codebase for existing patterns
3. Search Exa for external documentation and examples
4. Consider MCP Funnel for specialized tools

## Common Mistakes to Avoid

**Don't skip diagnostics:** "Tests pass" ≠ "No errors". Always check diagnostics.

**Don't forget to store learnings:** If you solved a problem, store it. Future you will thank you.

**Don't search externally first:** Check Cipher and codebase before searching external docs. Project-specific knowledge is more relevant.

**Don't ignore indexing status:** If Claude Context search returns nothing, check if codebase is indexed.

**Don't use MCP Funnel as first resort:** Core tools handle 95% of needs. Only use Funnel for specialized requirements.

## Tool Selection Decision Tree

```
Need to check for errors? → getDiagnostics
Need to remember past decisions? → ask_cipher (query)
Need to find existing code? → search_code
Need code examples/library docs? → get_code_context_exa (ALWAYS use Exa)
Need to search the web? → web_search_exa (ALWAYS use Exa, NOT WebSearch)
Need to fetch URL content? → crawling_exa (ALWAYS use Exa, NOT WebFetch)
Need specialized functionality? → discover_tools_by_words
Finished task? → getDiagnostics + ask_cipher (store)
```

**Remember:** NEVER use WebFetch or WebSearch - ALWAYS use Exa tools instead.
