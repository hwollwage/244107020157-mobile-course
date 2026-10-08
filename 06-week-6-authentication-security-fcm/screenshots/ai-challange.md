# AI Challenge – Week 6

## 1. Prompt used
See `docs/ai-initial-output.md` (prompt + raw output from Claude, unedited).

## 2. Verification checklist
| Check | Result | Evidence / what I found |
|---|---|---|
| Background handler is top-level with @pragma('vm:entry-point') | Pass | Top-level function, annotated, does not use BuildContext. Kept as is. |
| onTokenRefresh sends the new token to the backend | Partial | It calls sendTokenToBackend, but the call is not guarded. If the backend throws (mine is a mock URL), `init()` aborts before subscribing to the topic and registering listeners. The refresh listener also leaks an unhandled async error. |
| Foreground uses a manual local notification | Pass, with a bug | `_local.show` is used. But the draft also enables iOS foreground presentation, which would show a duplicate banner (system + local) on iOS. |
| Clicks from foreground/background/terminated land on the correct route | Needs proof | All three paths exist (local payload, onMessageOpenedApp, getInitialMessage). `init()` calls getInitialMessage, so if init runs before the router exists, navigation is lost. Proven with the test table below. |
| No hardcoded secrets / no full token logging | Fail | The token is logged in full twice (`getToken` and `onTokenRefresh`). |
| Route parsing is testable | Weak | `data['route'] ?? '/'` is repeated 3 times inside the service, so it cannot be unit tested. |

## 3. Manual fix list
1. Wrapped the token upload in try/catch so a backend failure no longer stops topic subscription or listeners (`main.dart` onToken).
2. Removed full token logging. The Debug page shows only the first 12 characters.
3. Removed the iOS foreground presentation override, because the app shows the banner manually and the override would duplicate it.
4. Moved navigation start to after the first frame (`addPostFrameCallback`), so `getInitialMessage` runs when the router is ready.
5. Extracted `routeFromMessage()` as a pure function in `routes.dart` and unit tested it.
6. Split the draft into small top-level functions (as in the codelab) instead of one class, so each step (permission, token, handlers) can be explained and tested separately.

## 4. Final decision and rationale
I accepted the AI structure (permission -> local notification init -> token -> listeners) and the top-level background handler because they match how FCM isolates work.
I rejected full token logging (a token identifies the device and could be used to send it messages), the unguarded backend call (one failed request should not disable push), and the iOS foreground override (duplicate banners).
The fixes were verified by the three-state test table, not only by reading code.

## 5. Android 13+ vs iOS, and BuildContext
- Differs: Android 13+ needs the runtime POST_NOTIFICATIONS permission; iOS needs the permission dialog and an APNs key in Firebase.
- Must never touch BuildContext: the background handler (separate isolate) and PushService itself (it receives a `navigate` callback instead).