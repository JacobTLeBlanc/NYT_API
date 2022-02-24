import json
import logging
import urllib.request as request
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

key = os.getenv('KEY')

def get_categories():
    """
    Gets New York Times Category names for different lists

    Returns
    -------
    json
        a json object representing a list of categories
    """

    response = request.urlopen(
            request.Request(
                url="https://api.nytimes.com/svc/books/v3/lists/names.json?api-key=" + key,
                headers={
                    'Accept': 'application/json',
                },
                method='GET'
            ),
            timeout=5
        )

    return json.loads(response.read())

def lambda_handler(event, context):

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(get_categories())
    }