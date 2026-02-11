# Technical Notes

## Helper Data Defaults

The backend currently does not return the specific user's position or estimated wait time in the `/queue_status` endpoint.
The Frontend `QueueStatus` model defaults these values to `0` to prevent crashes.

**Affected Fields:**
- `userPosition`: Defaults to `0`.
- `userEstimatedWaitMinutes`: Defaults to `0`.

**Future Improvement:**
Backend should be updated to accept `user_id` in `/queue_status` and return the specific position of that user in the queue.
