import boto3
import os

ses = boto3.client('ses')

def lambda_handler(event, context):
    source_email = 'diwakarsetty79@gmail.com' # replace with your desired source email address
    to_emails = ['settydiwakar@gmail.com', 'vemulatharun790@gmail.com'] # add your desired recipient email addresses here
    subject = 'Hello from the mass emailer'
    body = 'This is a test email sent using the AWS SES and Lambda mass emailer.'

    for to_email in to_emails:
        response = ses.send_email(
            Destination={
                'ToAddresses': [
                    to_email,
                ],
            },
            Message={
                'Body': {
                    'Text': {
                        'Data': body,
                    },
                },
                'Subject': {
                    'Data': subject,
                },
            },
            Source=source_email,
        )
