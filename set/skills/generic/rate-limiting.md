# Rate limiting

Treat HTTP 429 and explicit rate-limit responses as feedback, not as
transient failures to hammer through. Retry only when the operation is safe
to repeat (or has an idempotency key), and make the retry policy bounded and
observable.

- Prefer the server's `Retry-After` value. Accept both delta-seconds and an
  HTTP date, and wait until that time before retrying. Also inspect documented
  reset, remaining, and limit headers; if the response says the window is
  exhausted, do not start more work during that window.
- When no usable server delay is provided, use exponential backoff, for
  example `base * 2^attempt`, with a reasonable maximum delay and a maximum
  number of attempts. Add bounded random jitter so concurrent workers do not
  retry in lockstep.
- A server-provided delay is authoritative, subject only to a configured
  safety ceiling. Never replace a longer `Retry-After` with a shorter local
  exponential delay; if the ceiling would be exceeded, fail clearly instead
  of retrying early.
- Reduce concurrency when a limit is reached. Coordinate retries through a
  shared per-endpoint or per-origin limiter where possible, and restore
  concurrency gradually after successful requests. A retry loop must not
  multiply the number of in-flight requests.
- Apply the same policy to 429 responses and other explicitly documented
  rate-limit signals. Preserve the final status, response body, request
  context, and attempt count in the error or logs, while avoiding credentials
  and other sensitive headers.
- Stop after the configured retry budget, including when a server supplies a
  delay. Report that the budget was exhausted rather than silently issuing an
  unbounded series of delayed requests.

Test the policy with a server or transport double that returns 429 responses
with delta and HTTP-date `Retry-After` values, then succeeds. Assert that no
request is made before the advised time, that backoff grows when feedback is
absent, that jitter stays within its bounds, and that retries stop at the
configured limit. Also test that concurrent callers honor the endpoint's
connection limit.
