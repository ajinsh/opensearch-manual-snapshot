# Automating daily manual snapshots for Amazon OpenSearch Service as per custom retention period

This repo contains the source code for Sample Lambda Function to automate the manual snapshots in Amazon Opensearch Search using serverless technology 
i.e. Amazon Lambda and Amazon EventBridge. Other solutions involve using the Index State Management Policy feature of including [snapshot](https://opendistro.github.io/for-elasticsearch-docs/docs/im/ism/policies/#snapshot) operation in the ISM Supported list of operations.

> Use Case: Retain X number of snapshots in the manual snapshot repository and take manual snapshots as per cron schedule


## File Structure
```
| Opensearch-Manual-Snapshot.zip
  |-lambda_function.py
  |-CustomSnapshot.py
```

## Getting Started
The following steps outline how to implement the solution.

#### Step 1: Pre-requisites ##### 

* Create a brand new Amazon Opensearch Domain optionally with Fine-Grained Access Control Enabled. Else, use existing domain if you have.

#### Step 2: Modifying the Lambda Code ##### 

* Extract the  `Opensearch-Manual-Snapshot.zip` file locally and unzip it.
* Modify the `lambda_function.py` and pass the arguments to the instance of the class `CustomSnapshot` as per your requirement.
Class `CustomSnapshot` __init__() has parameters:  `host`, `region`, `service`, `repo`, `snapshot_prefix` defined as below:

  * `host`    : Amazon Opensearch Cluster Endpoint including https:// and trailing /
  * `region`  : Region of Amazon Opensearch Cluster
  * `service` : `es`
  * `repo`    : Enter the name for your manual snapshot repository.
  * `snapshot_prefix` : Enter the name of the prefix for your snapshot name. The snapshot name has naming scheme as
    `snapshot_prefix + %Y-%d-%mt%H:%M:%S%z`. For instance, snapshot taken on `14th Feb 2023 01:45:27 UTC` will have name as
    snapshot-2023-14-03t01:45:27+0000
    
*  Modify the `CustomSnapshot.py` and set the correct retention for variable `RETENTION_PERIOD`. By default, the value for this is set to 30.
This means at a given time there are only 30 snapshots in a given snapshot repository. Any snapshots older than 30 should not be present in the
manual snapshot repository. 

* After modifying the above files, zip it along with dependencies as a fresh zip deployment as per instructions listed as [Deployment package with dependencies](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html#python-package-create-package-with-dependency)
or as per below 
```
mkdir ../final-package
pip install --target ../final-package requests
pip install --target ../final-package requests_aws4auth
mv CustomSnapshot.py lambda_function.py six.py ../final-package/
cd ../final-package
zip -r ./Opensearch-Manual-Snapshot.zip .
```
Here the final deployment zip file is `Opensearch-Manual-Snapshot.zip`.


* Create a Lambda Function using option  "Author from scratch". Enter function-name. Select Runtime > Python 3.x. Please note that the lambda function test 
has been made using Python 3.9. Keep architecture "x86_64". Leave the advanced settings as default.  Finally, click on "Create Function".

* Once the function has been created, click on "Upload from" > ".zip file" and upload the `Opensearch-Manual-Snapshot.zip`.


#### Step 3: Create Amazon EventBridge Schedule as pr the custom CRON requirement ##### 

The cron schedule requirement is

| Field  | Values |  Wildcards | 
| ------ | ------ | ------ |
| Minutes	| 0-59		| , - * / |
| Hours	| 	0-23	| 	, - * / |
| Day-of-month	| 	1-31		| , - * ? / L W |
| Month	| 	1-12 or JAN-DEC		| , - * / |
| Day-of-week		| 1-7  or SUN-SAT		| , - * ? L # |
| Year		| 1970-2199		| , - * / |

For instance, inputting below cron schedule expression will invoke lambda function runs every 15 minutes every single day
between 8 AM till 5 PM local time.

 | 0/15  | 8-17  |  * |  * |  ?  | * |
 | ------ | ------ | ------ | ------ | ------ | ------ |
| Minutes | Hours |Day of month | Month  |Day of week  |Year |

####  Step 4: Confirm Snapshot Creation ####  

Use the `GET _cat/snapshots/<repo>?v&s=end_epoch` to confirm that snapshots are taken every 15 minutes every single day
between 8 AM till 5 PM local time or as per your custom cron schedule.


####  Step 5: Upcoming /WIP ####  

We can further improve this by automating the infrastructure using AWS CloudFormation and using parameterized templates to accept user inputs
for `host`, `region`, `repo`, `snapshot_prefix` of Step 1.

####################################################################################################
### P.S: Please fork this repository or make a pull request to give due credits for the work or for making additional improvements. Any code  plagiarism is strictly disdained.
