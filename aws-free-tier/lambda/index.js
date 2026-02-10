// ============================================
// Visitor Counter Lambda Function
// ============================================

const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.TABLE_NAME;
const COUNTER_ID = "visitor-count";

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    try {
        // Get current count
        const getParams = {
            TableName: TABLE_NAME,
            Key: {
                id: COUNTER_ID
            }
        };
        
        let currentCount = 0;
        
        try {
            const result = await ddbDocClient.send(new GetCommand(getParams));
            if (result.Item && result.Item.count) {
                currentCount = result.Item.count;
            }
        } catch (error) {
            console.log('Item not found, initializing counter');
        }
        
        // Increment count
        const newCount = currentCount + 1;
        
        // Update DynamoDB
        const putParams = {
            TableName: TABLE_NAME,
            Item: {
                id: COUNTER_ID,
                count: newCount,
                lastUpdated: new Date().toISOString()
            }
        };
        
        await ddbDocClient.send(new PutCommand(putParams));
        
        // Return response
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            body: JSON.stringify({
                count: newCount,
                message: 'Visitor count updated successfully',
                timestamp: new Date().toISOString()
            })
        };
        
    } catch (error) {
        console.error('Error:', error);
        
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                error: 'Internal server error',
                message: error.message
            })
        };
    }
};
