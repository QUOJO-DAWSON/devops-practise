# API Testing

## Running Tests

### Prerequisites
- Node.js installed
- API endpoint deployed

### Execute Tests

\\\ash
cd tests
node api-tests.js
\\\

### With Custom Endpoint

\\\ash
API_ENDPOINT=https://your-api.execute-api.us-east-2.amazonaws.com node api-tests.js
\\\

## Expected Output

\\\
=======================================
  Visitor Counter API Integration Tests
=======================================

Testing Visitor Counter API...

Test 1: API returns HTTP 200
Pass: API returned 200 OK

Test 2: Response contains required fields
Pass: All required fields present

Test 3: Count is a valid number
Pass: Count is valid number (42)

Test 4: Timestamp is valid ISO 8601 format
Pass: Timestamp is valid

Test 5: Response has correct headers
Pass: Headers are correct

Test 6: Count increments on subsequent requests
Pass: Count incremented (42 to 43)

=======================================
ALL TESTS PASSED
=======================================
API Endpoint: https://mmavaok010.execute-api.us-east-2.amazonaws.com/count
Current Count: 43
Timestamp: 2026-02-25T10:30:00.000Z
=======================================

Execution time: 1234ms
\\\

## Test Coverage

The test suite validates:
- HTTP status code (200 OK)
- Response structure (count, message, timestamp fields)
- Data types (number for count, valid ISO timestamp)
- Header validation (application/json content type)
- State mutation (counter increments correctly)

These tests ensure the API behaves correctly and maintains data integrity across requests.

## Future Enhancements

- Error handling tests (invalid requests)
- Performance benchmarks (latency measurements)
- Load testing (concurrent request handling)
- Edge case validation (boundary conditions)
