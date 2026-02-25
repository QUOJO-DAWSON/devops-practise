const https = require('https');

const API_ENDPOINT = process.env.API_ENDPOINT || 'https://mmavaok010.execute-api.us-east-2.amazonaws.com';

async function makeRequest(path) {
  return new Promise((resolve, reject) => {
    const url = "${API_ENDPOINT}${path}";
    
    https.get(url, (res) => {
      let data = '';
      
      res.on('data', chunk => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          resolve({ 
            status: res.statusCode, 
            data: JSON.parse(data),
            headers: res.headers
          });
        } catch (error) {
          reject(new Error("Failed to parse response: ${error.message}"));
        }
      });
    }).on('error', (error) => {
      reject(error);
    });
  });
}

async function testVisitorCounter() {
  console.log('Testing Visitor Counter API...\n');
  
  let allTestsPassed = true;
  
  try {
    console.log('Test 1: API returns HTTP 200');
    const response = await makeRequest('/count');
    
    if (response.status !== 200) {
      throw new Error("Expected status 200, got ${response.status}");
    }
    console.log('Pass: API returned 200 OK\n');
    
    console.log('Test 2: Response contains required fields');
    if (!response.data.count) {
      throw new Error('Response missing count field');
    }
    if (!response.data.message) {
      throw new Error('Response missing message field');
    }
    if (!response.data.timestamp) {
      throw new Error('Response missing timestamp field');
    }
    console.log('Pass: All required fields present\n');
    
    console.log('Test 3: Count is a valid number');
    if (typeof response.data.count !== 'number') {
      throw new Error("Count is not a number: ${typeof response.data.count}");
    }
    if (response.data.count < 0) {
      throw new Error("Count is negative: ${response.data.count}");
    }
    console.log("Pass: Count is valid number (${response.data.count})\n");
    
    console.log('Test 4: Timestamp is valid ISO 8601 format');
    const timestamp = new Date(response.data.timestamp);
    if (isNaN(timestamp.getTime())) {
      throw new Error("Invalid timestamp: ${response.data.timestamp}");
    }
    console.log('Pass: Timestamp is valid\n');
    
    console.log('Test 5: Response has correct headers');
    if (!response.headers['content-type']?.includes('application/json')) {
      throw new Error('Content-Type is not application/json');
    }
    console.log('Pass: Headers are correct\n');
    
    console.log('Test 6: Count increments on subsequent requests');
    const response2 = await makeRequest('/count');
    if (response2.data.count <= response.data.count) {
      throw new Error('Count did not increment');
    }
    console.log("Pass: Count incremented (${response.data.count} to ${response2.data.count})\n");
    
    console.log('=======================================');
    console.log('ALL TESTS PASSED');
    console.log('=======================================');
    console.log("API Endpoint: ${API_ENDPOINT}/count");
    console.log("Current Count: ${response2.data.count}");
    console.log("Timestamp: ${response2.data.timestamp}");
    console.log('=======================================\n');
    
  } catch (error) {
    console.error('TEST FAILED:', error.message);
    console.error('\nStack trace:', error.stack);
    allTestsPassed = false;
  }
  
  return allTestsPassed;
}

async function runTests() {
  console.log('=======================================');
  console.log('  Visitor Counter API Integration Tests');
  console.log('=======================================\n');
  
  const startTime = Date.now();
  const success = await testVisitorCounter();
  const duration = Date.now() - startTime;
  
  console.log("Execution time: ${duration}ms\n");
  
  process.exit(success ? 0 : 1);
}

runTests();
