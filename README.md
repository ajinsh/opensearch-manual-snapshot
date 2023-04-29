# Automating manual snapshots for Amazon OpenSearch Service as per custom retention period

## Architecture Flow 

![Opensearch Snapshot Flow](https://github.com/ajinsh/opensearch-manual-snapshot/blob/main/opensearch-manual-snapshot-flow.png)

---

This repo contains the source code for Sample Lambda Function to automate the manual snapshots in Amazon Opensearch Search using serverless technology 
i.e. Amazon Lambda and Amazon EventBridge. Other solutions involve using the Index State Management Policy feature of including [snapshot](https://opendistro.github.io/for-elasticsearch-docs/docs/im/ism/policies/#snapshot) operation in the ISM Supported list of operations.

> Use Case: Retain X number of snapshots in the manual snapshot repository and take manual snapshots as per cron schedule


## Folder Structure
```
| function (This folder contains the Lambda Function Code to perform the manual snapshot)
  |-lambda_function.py
  |-CustomSnapshot.py
  
  
| templates (This folder contains the CloudFormation Template File)
  |-resources.yml
  

| *.sh (Shell Scripts to perform the deployment)
```

## Getting Started
The following steps outline how to implement the solution.


#### Step 1: Set total number of snapshots to retain and snapshot-suffix name ##### 

* Open the terminal or command prompt on your local machine. Navigate to the directory where you want to clone the repository.
* Run the following command to clone the repository:
```
git clone https://github.com/ajinsh/opensearch-manual-snapshot.git
```
* Once the repository is cloned, you can navigate into the repository directory by running:
```
cd opensearch-manual-snapshot
```
* Go to `function/` folder 
* Modify the `CustomSnapshot.py` to set the retention on the total number of snapshots. Class `CustomSnapshot` __init__() has RETENTION_PERIOD as the class variable which can be set to total number of snapshots to be retained. In the code, by default, the value for this is set to 30. This means at a given time there are only 30 snapshots in a given snapshot repository. Any snapshots older than 30 should not be present in the manual snapshot repository.
 
The snapshots stored inside the manual snapshot repository have below naming scheme `snapshot_prefix` : Enter the name of the prefix for your snapshot name. The snapshot name has naming scheme as`snapshot_prefix + %Y-%d-%mt%H:%M:%S%z`. For instance, snapshot taken on `14th Feb 2023 01:45:27 UTC` will have name as snapshot-2023-14-03t01:45:27+0000  if `snapshot_prefix` is "snapshot-". You dont need to set `snapshot_prefix` in code but via CFN Stack Parameters later.
 
You can modify the suffix part and set to custom datetimestring that you would like which equates to `"%Y-%m-%dt%H:%M:%S%z` for variable `snapshot_name`
    
#### Step 2. Install and configure AWS CLI in code environment ####  
* Install  AWS CLI on command-prompt/shell using instructions [Getting started with the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

* Configure AWS CLI with either an IAM User / IAM Role with access to  cloudformation:* and s3:* permissions. These permissions are required to create S3 buckets which holds the manual-snapshot(which is registered with OpenSearch) and the deployment package for lambda function. The Cloudformation permissions are required for creating CFN stack and deploy the whole pipeline.

#### Step 3. Run the SH scripts in order ####  

* Run `0.build.sh` to generate bucket-name.txt containing 2 lines
  - `lambda-artifacts-<HEX-CODE>`
  - `snapshot-bucket-<HEX-CODE>`

* Run `1.build.sh` to build the deployment package based on code stored in `function\` and upload it to `lambda-artifacts-<HEX-CODE>`

* Run `3.deploy.sh` to deploy the CFN Stack to the region(default region configured on your AWS CLI)
  
#### Step 4. Pass parameter to the CFN Stack ##### 
 
Refer below to see how the parameters have been passed to the CFN Stack.
  
![CloudFormation Stack parameters](https://github.com/ajinsh/opensearch-manual-snapshot/blob/main/CloudFormation-Stack-Parameters.png)
  
***Note: Guidelines for CFN Parameters***
> 
> * You will have to pass the cron expression in double quotes for CFN Stack to run successfully. In my sample run, I passed parameter as "cron(59/59 16-18 * * ? *)"  which has double quotes.
> * For subnets, pass comma seperated list of subnets for selecting multiple subnets in given VPC. 
> * For parameter S3bucketName, set it to value `lambda-artifacts-<HEX-CODE>` from bucket-name.txt file generated (line 1 of file).
> * For parameter SnapshotRepoName, set it to value `snapshot-bucket-<HEX-CODE>` from bucket-name.txt file generated (line 2 of file).
  
As per [Creating an Amazon EventBridge rule that runs on a schedule - Cron Expressions](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html#eb-cron-expressions), the cron schedule parameters are as below:


| Field  | Values |  Wildcards | 
| ------ | ------ | ------ |
| Minutes	| 0-59		| , - * / |
| Hours	| 	0-23	| 	, - * / |
| Day-of-month	| 	1-31		| , - * ? / L W |
| Month	| 	1-12 or JAN-DEC		| , - * / |
| Day-of-week		| 1-7  or SUN-SAT		| , - * ? L # |
| Year		| 1970-2199		| , - * / |

For instance, inputting cron schedule expression as "cron(0/15 8-18 * * ? *)" will invoke lambda function runs every 15 minutes every single day
between 8 AM till 5 PM local time.

 | 0/15  | 8-17  |  * |  * |  ?  | * |
 | ------ | ------ | ------ | ------ | ------ | ------ |
| Minutes | Hours |Day of month | Month  |Day of week  |Year |

####  Step 4: Confirm Snapshot Creation ####  

Use the `GET _cat/snapshots/<repo>?v&s=end_epoch` to confirm that snapshots are taken every 15 minutes every single day
between 8 AM till 5 PM local time or as per your custom cron schedule.

If this is first time, snapshot repository registration will happen and after which the first snapshot will be taken. Once the solution has been deployed, you can check the above APIs to confirm if the snapshot registration is happening successfully.
  
--- 

# License


Copyright 2023 Ajinkya Shinde

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
