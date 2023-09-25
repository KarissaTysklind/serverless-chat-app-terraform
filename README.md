# Serverless Instant Messaging Application Infrastructure as Code
Welcome to the README for the Serverless Instant Messaging Application project, showcasing the implementation of an instant messaging app using a serverless architecture. This README provides an overview of the project's infrastructure as code, focusing on the utilization of AWS services including S3, CloudFront, Lambda Functions, API Gateway, DynamoDB, and Cognito.

# Project Overview
The Serverless Instant Messaging Application is designed to provide a seamless messaging experience while leveraging the power of AWS serverless services. The architecture is split into front-end and back-end components, enabling efficient communication between users.

# Front-end Infrastructure
The front end is hosted as a static website on Amazon S3, ensuring fast and reliable content delivery. This static website is fronted by Amazon CloudFront, a content delivery network that enhances the website's performance and reduces latency for users across the globe. 

# Back-end Infrastructure
The back end is powered by AWS Lambda Functions, which are triggered by API Gateway resources. API Gateway handles both the GET and POST HTTP methods, enabling communication between the front end and back end. User conversations and messages are stored in Amazon DynamoDB, a highly scalable and fully managed NoSQL database.

User management and authentication are handled by Amazon Cognito, providing secure user sign-up, sign-in, and access control for the application.

# Requirements
For this task you will need the following:
    -   A Free Tier AWS Account
    -   Terraform installed in your computer
    -   AWS CLI installed in your computer
    -   AWS Access Keys

For details on how to set up an AWS account, how to set up Terraform and AWS CLI in your computer follow these links.

# Getting Started
To deploy and run the Serverless Instant Messaging Application, follow these steps:

1. Download Terraform Files:

    -   Download the contents of this directory or create your own copy on a new directory on GitHub.
    -   To work on your files, use your favourite text editor and open your folder/directory.
    -   Using the Command Line, log into your AWS account using the <aws configure> command. 
    -   Log in with your own AWS Access Key ID and AWS Secret Access Key. 
    -   Specify the region where you would like to deploy your application. For example: <us-east-1>
    -   Set default output format to <json>

2. Initialize Terraform:

    -   Using the Command Line, initialize terraform with <terraform init>
    -   Feel free to run <terraform validate> and <terraform fmt> to validate and reformat your files
    -   If you want to automatically specify all the variables, create a <terraform.tfvars> file in the same directory
    -   Include the following string variables as follows with your own values for each variable:

                aws_region = ""

                s3_bucket_name     = ""
                lambda_bucket_name = ""

                dynamodb_conversation_table_name = ""
                dynamodb_messages_table_name     = ""

                chat_dynamoDB_policy_name  = ""
                lambda_cognito_policy_name = ""

                chat_dynamoDB_role_name  = ""
                lambda_cognito_role_name = ""
                lambda_layer_name = ""

                cognito_user_pool_name = ""

                function_name_prefix = ""

                api_chat_name          = ""
                api_stage_name         = ""
                endpoint_configuration = ""

                sdk_file_name = ""

3. Deploy terraform files:

    -   Use <terraform plan> to run a preview of your deployment.
    -   Use <terraform apply> to deploy the AWS resources defined on your terraform folder 

4. Download API SDK files.
    
    -   Using the AWS Management Console, Navigate to the API Gateway and Select the API associated to this deployment.
    -   Navigate to Stages, select the current stage, and select SDK Generation.
    -   Under the <Platform*> dropdown menu select <JavaScript>
    -   Proceed to <Generate SDK> to download your API files.
    -   Extract the dowloaded zip file
    -   Using the management console upload the <apiGateway-js-sdk> folder to <your_s3_folder_name/js>   

# Contribution and Feedback
Contributions, bug reports, and feedback are welcome! If you encounter issues or have suggestions for improvements, please create an issue in this repository.

# License
This project is licensed under the MIT License.

By following this README, you'll be able to deploy and run the Serverless Instant Messaging Application with ease. Feel free to adapt and expand upon the infrastructure as needed for your specific use case. If you have any questions or need assistance, don't hesitate to reach out.