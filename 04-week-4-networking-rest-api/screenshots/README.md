# AI verification checklist
## - no, only passing CommentRepository
## - yes, using "as num?", "as String?", all of them has "?? default"
## - yes, timeout, connection error, badresponse with 404 401 403
## - baseUrl yes, but 10sec in claude put per-request
## - no, the test only for missing field cases, add 1 mroe happy test path so theres 2 cases
## - test result in screenshots/

# Reflection
## - every widget that needs data hass to duplicate networking logic, if api changes we fix it in N places instead of 1
## - we cant test the ui without a real network call, since theres not repo to swap for a fake one in test
## - error handling gets inconsistent, one widget might show raw DioException text, other might crash & silently show nothing
## - state managemtn breaks down, riverpod's asnyval only workjs cleanly when theres a signle provider watching a signle data soruce