# Week 10: AI Feature Integration

## AI-Powered Campus Chat

This application provides an optional AI-powered campus chat feature using Google's Gemini API. Users can access it through **AI Chat** on the home screen and configure their Gemini API key by tapping the key icon.

For security, the API key is saved using `flutter_secure_storage`. When making API requests, the key is passed through the `x-goog-api-key` HTTP header rather than being embedded in the source code, logs, or request URL. Users can also remove their saved API key whenever they no longer need the service.

The chat feature uses the following architecture to maintain separation between the UI and business logic:

```text
Chat Screen -> Riverpod ChatNotifier -> AiRepository -> AiService
```

The `ChatNotifier` handles streaming responses and updates the message list as new text arrives. It also supports retrying failed requests, stores up to 30 previously successful answers in an in-memory cache, and enforces a two-second cooldown between new API requests.

When a question has already been answered and its result is available in the cache, the application can reuse that response without making another API call. Cached data is temporary and will be cleared once the application process is terminated.

### Privacy, Security, and API Cost Considerations

| Potential Risk | Implemented Solution |
| --- | --- |
| Personal information such as NIK or phone numbers being shared with the AI | The application detects common 16-digit NIK formats and Indonesian phone number patterns, replaces detected information before sending the request, and notifies the user. |
| Gemini API key being exposed | The key is kept in secure device storage and transmitted through an HTTP header instead of being included in the source code or URL. |
| Unexpected or invalid AI responses | The application filters control characters, limits responses to 2,000 characters, and handles empty or incorrectly formatted responses with an error message. |
| Excessive API usage and unexpected costs | A two-second request cooldown and an in-memory cache help reduce unnecessary requests. Gemini rate-limit errors are also handled with a retry option. |
| Network problems or unavailable AI services | The application initially uses `gemini-3.1-flash-lite`. If the service returns HTTP 503, it makes one additional attempt using `gemini-3.8-flash`. Other errors are handled separately, while HTTP 429 responses are not retried using another model. |

The application only sends the sanitized user message along with a predefined system instruction. It does not currently provide Gemini with additional information such as student profiles, academic schedules, or other personal context.

Although automatic redaction provides an additional layer of protection, it cannot recognize every possible form of sensitive information. Therefore, users are still advised not to enter confidential or personal data into the chat.

### Testing and Verification

The implementation was checked using the following Flutter commands:

- `flutter analyze` to identify potential code issues.
- `flutter test` to execute the automated unit tests.

The test suite covers several important components, including:

- Personal information detection and redaction.
- AI response validation and output handling.
- Secure API key storage.
- Server-Sent Events (SSE) parsing.
- Streaming response processing.
- Missing API key scenarios.
- Network and offline error handling.
- HTTP 429 rate-limit responses.
- Empty and malformed AI responses.

For manual testing, the application can be installed on a physical device or emulator. After saving a valid Gemini API key in the AI Chat settings, users can send a non-sensitive question and check whether the response appears progressively.

Additional scenarios should also be tested, including an empty API key, airplane mode, API rate limits, and messages containing sample Indonesian phone numbers or NIK patterns.

**Latest test results:**
- `flutter analyze`: No issues found.
- `flutter test`: All 33 tests passed.
- `flutter build apk --debug`: Build completed successfully.

One important limitation of this implementation is that the Gemini API key is stored on the user's device. This approach is acceptable for an educational project, but it is not recommended for a production application because API credentials distributed with a mobile client may be extracted. A more secure production architecture would handle Gemini API requests through an authenticated backend server.

## Reflection

**1. Which AI feature did you implement, and why did you choose it?**

I implemented an AI-powered campus chat using Gemini. I chose this feature because it is relevant to the application's academic environment and provides students with a convenient way to ask questions and receive information through a conversational interface. It also follows the chat implementation approach introduced in the codelab.

**2. How do you maintain user privacy when communicating with an AI API?**

The Gemini API key is stored using the device's secure storage and transmitted through an HTTP request header, keeping it out of the source code and URL. Before sending a message, the application checks for common NIK and Indonesian phone number patterns and replaces any detected information with redacted text. The user is also informed when sensitive patterns are detected. However, this protection is not perfect, so users should avoid sharing confidential information.

**3. What happens when the AI service becomes unavailable or returns an error?**

The application has several error-handling mechanisms. If the primary model, `gemini-3.1-flash-lite`, returns an HTTP 503 error, the application automatically attempts one retry using `gemini-3.8-flash`.

For other situations, such as missing API keys, network interruptions, HTTP 429 rate limits, timeouts, or invalid responses, the application displays an understandable error message and provides an option to retry. It also reuses previously generated answers through its temporary cache to minimize unnecessary API calls. However, the chat feature still requires an active internet connection and does not support offline responses.

**4. What did you learn about designing AI-powered features for mobile applications?**

I learned that integrating AI into a mobile application involves more than simply connecting to an API. The user experience also depends on how the application handles loading states, response delays, and unexpected errors.

Displaying responses as they are generated makes the interaction feel more responsive. In addition, preventing multiple submissions while a request is processing and providing a retry option helps users understand what is happening when something goes wrong. Security, privacy, and API usage management are also important considerations when developing AI-powered mobile features.
