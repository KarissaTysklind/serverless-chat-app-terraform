# Serverless Instant Messaging Application Infrastructure as Code
Welcome to the README for the Serverless Instant Messaging Application project, showcasing the implementation of an instant messaging app using a serverless architecture. This README provides an overview of the project's infrastructure as code, focusing on the utilization of AWS services including S3, CloudFront, Lambda Functions, API Gateway, DynamoDB, and Cognito.

# Project Overview
The Serverless Instant Messaging Application is designed to provide a seamless messaging experience while leveraging the power of AWS serverless services. The architecture is split into front-end and back-end components, enabling efficient communication between users.

# Front-end Infrastructure
The front end is hosted as a static website on Amazon S3, ensuring fast and reliable content delivery. This static website is fronted by Amazon CloudFront, a content delivery network that enhances the website's performance and reduces latency for users across the globe. 

# Back-end Infrastructure
The back end is powered by AWS Lambda Functions, which are triggered by API Gateway resources. API Gateway handles both the GET and POST HTTP methods, enabling communication between the front end and back end. User conversations and messages are stored in Amazon DynamoDB, a highly scalable and fully managed NoSQL database.

User management and authentication are handled by Amazon Cognito, providing secure user sign-up, sign-in, and access control for the application.

# Getting Started
To deploy and run the Serverless Instant Messaging Application, follow these steps:

1. Front-end Deployment:

    -   Upload the contents of the frontend/ directory to an S3 bucket.
    -   Create a CloudFront distribution for the S3 bucket to enhance content delivery.

2. Back-end Deployment:

    -   Navigate to the backend/ directory.
    -   Use the Serverless Framework and the serverless.yml configuration to deploy Lambda Functions and API Gateway resources.
    -   Create the DynamoDB tables and configure Cognito according to the settings in the CloudFormation templates provided in the cloudformation/ directory.

3. Connecting Front-end and Back-end:

    -   Update the necessary API endpoints and other configuration settings in the front-end code to interact with the deployed back-end services.

4.  Testing:

    -   Open the deployed S3 static website in a browser and start using the instant messaging application.

# Contribution and Feedback
Contributions, bug reports, and feedback are welcome! If you encounter issues or have suggestions for improvements, please create an issue in this repository.

# License
This project is licensed under the MIT License.

By following this README, you'll be able to deploy and run the Serverless Instant Messaging Application with ease. Feel free to adapt and expand upon the infrastructure as needed for your specific use case. If you have any questions or need assistance, don't hesitate to reach out.