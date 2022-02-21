import json
import logging
import urllib.request as request
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

key = os.getenv('KEY')

def get_best_sellers(date, category):
    """
    Gets New York Times Best Sellers given the category/date

    Params
    -------
    date
        date of best sellers

    category
        category of best sellers (hardcover-fiction, young-adult, etc.)

    Returns
    -------
    json
        a json object representing a list of (public) repositories
    """

    response = request.urlopen(
            request.Request(
                url="https://api.nytimes.com/svc/books/v3/lists//" + date + "/" + category + ".json?api-key=" + key,
                headers={
                    'Accept': 'application/json',
                },
                method='GET'
            ),
            timeout=5
        )

    return json.loads(response.read())

def lambda_handler(event, context):

    category = event['pathParameters']['category']
    date = event['pathParameters']['date']

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(get_best_sellers(date, category))
    }