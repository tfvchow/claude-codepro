---
name: Error Handling Standards
description: Implement robust error handling with fail-fast validation, specific exception types, centralized handling at boundaries, exponential backoff retry strategies, and proper resource cleanup. Use this skill when implementing try/catch blocks, exception hierarchies, retry logic, or error recovery patterns. Apply when working with API error responses, database connection handling, file I/O operations, external service calls, or any code that needs graceful failure handling. Use for any task involving input validation, exception design, retry mechanisms, resource management, or user-facing error messages.
---

# Error Handling Standards

**Core Rule:** Fail fast, handle at boundaries, clean up resources, never expose internals to users.

## When to use this skill

- When implementing try/catch/finally blocks or exception handling
- When designing custom exception hierarchies for a module or service
- When adding retry logic for external service calls or network operations
- When handling database connections, file handles, or other resources that need cleanup
- When deciding where to catch vs. where to let exceptions bubble up
- When implementing input validation that should fail early
- When creating user-facing error messages from internal exceptions
- When adding logging for debugging while keeping user messages safe

## Fail Fast

Validate inputs early. Throw specific exceptions rather than returning null or allowing invalid state.

```python
def process_order(order_id: str, quantity: int) -> Order:
    if not order_id:
        raise ValueError("order_id is required")
    if quantity <= 0:
        raise ValueError("quantity must be positive")
    # Proceed with valid inputs
```

## Exception Types

Use specific exception types (not generic `Exception`). Create hierarchies for related errors.

```python
class PaymentError(Exception):
    """Base exception for payment processing."""
    pass

class InsufficientFundsError(PaymentError):
    """Raised when account balance is too low."""
    pass

class PaymentGatewayError(PaymentError):
    """Raised when external gateway fails."""
    pass
```

## Centralized Handling

Handle errors at boundaries (controllers, API layers). Let exceptions bubble up to centralized handlers.

```python
# DON'T: Catch and suppress everywhere
def get_user(id):
    try:
        return db.find_user(id)
    except Exception:
        return None  # Hides the real problem

# DO: Let it bubble up to the boundary
def get_user(id):
    return db.find_user(id)  # Raises if not found

# Handle at the API boundary
@app.route("/users/<id>")
def user_endpoint(id):
    try:
        return jsonify(get_user(id))
    except UserNotFoundError:
        return jsonify({"error": "User not found"}), 404
    except DatabaseError:
        logger.exception("Database error")
        return jsonify({"error": "Internal error"}), 500
```

## Retry Strategies

Use exponential backoff for transient failures (network timeouts, 503, 429). Never retry non-idempotent operations or client errors (400, 401, 404).

```python
import time
from random import uniform

def retry_with_backoff(func, max_retries=3, base_delay=1.0):
    for attempt in range(max_retries):
        try:
            return func()
        except (TimeoutError, ServiceUnavailableError) as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt) + uniform(0, 1)
            time.sleep(delay)
```

**Retry these:** Network timeouts, 503 Service Unavailable, 429 Too Many Requests, connection reset

**Never retry:** 400 Bad Request, 401 Unauthorized, 404 Not Found, POST/PUT/DELETE without idempotency keys

## Resource Cleanup

Always clean up resources (connections, file handles) in finally blocks or context managers.

```python
# DO: Use context managers
with open("file.txt") as f:
    data = f.read()

# DO: Use finally for manual cleanup
connection = None
try:
    connection = db.connect()
    connection.execute(query)
finally:
    if connection:
        connection.close()
```

## User Messages

Log technical details for debugging. Show safe, actionable messages to users without exposing internals.

```python
try:
    result = process_payment(card_number, amount)
except PaymentGatewayError as e:
    # Log full details for debugging
    logger.error(f"Payment failed: {e}", exc_info=True, extra={
        "amount": amount,
        "gateway_code": e.code
    })
    # Show safe message to user
    raise UserFacingError("Payment could not be processed. Please try again.")
```

**Never expose to users:**
- Stack traces
- Database error messages
- Internal file paths
- API keys or credentials in error context

## Verification Checklist

Before completing error handling work:
- [ ] Inputs validated early (fail fast)
- [ ] Specific exception types used (not generic Exception)
- [ ] Exceptions bubble to boundaries (not caught everywhere)
- [ ] Retry logic only for transient, idempotent operations
- [ ] Resources cleaned up in finally/context managers
- [ ] User messages are safe and actionable
- [ ] Technical details logged for debugging
