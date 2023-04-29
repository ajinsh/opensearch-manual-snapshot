#!/bin/bash

## Accesing the lambda S3 Bucket and the Opensearch S3 Bucket
LAMBDA_S3_BUCKET=$(sed -n '1p' bucket-name.txt)
SNAPSHOT_REPO_S3_BUCKET=$(sed -n '2p' bucket-name.txt)

echo "$LAMBDA_S3_BUCKET"
echo "$SNAPSHOT_REPO_S3_BUCKET"

# Declare an array with 18 variable names
vars=("AOSSVersion" "AZCount" "DataInstanceCount" "DataInstanceType" "LambdaFunctionName" "LambdaIAMRole" "MasterInstanceCount" "MasterInstanceType" "MasterUName" "MasterUPWD" "OpensearchDomainName" "OpensearchVPC" "OpensearchVPCSG" "OpensearchVPCSubnet"  "SchedulerExpression" "SnapshotPrefix" )


# Prompt the user to enter 18 CloudFormation parameter values
for var in "${vars[@]}"
do
    read -p "Enter value for ${var}: " input
    eval "${var}=${input}"
done


# Print out the values of the variables
for var in "${vars[@]}"
do
    echo "${var}=${!var}"
done

# Use the AWS CLI to create a CloudFormation stack with the specified parameters
aws cloudformation create-stack \
--stack-name MyStack \
--template-body file://templates/resources.yml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=AOSSVersion,ParameterValue=${vars[0]} \
            ParameterKey=AZCount,ParameterValue=${vars[1]} \
            ParameterKey=DataInstanceCount,ParameterValue=${vars[2]} \
            ParameterKey=DataInstanceType,ParameterValue=${vars[3]} \
            ParameterKey=LambdaFunctionName,ParameterValue=${vars[4]} \
            ParameterKey=LambdaIAMRole,ParameterValue=${vars[5]} \
            ParameterKey=MasterInstanceCount,ParameterValue=${vars[6]} \
            ParameterKey=MasterInstanceType,ParameterValue=${vars[7]} \
            ParameterKey=MasterUName,ParameterValue=${vars[8]} \
            ParameterKey=MasterUPWD,ParameterValue=${vars[9]} \
            ParameterKey=OpensearchDomainName,ParameterValue=${vars[10]} \
            ParameterKey=OpensearchVPC,ParameterValue=${vars[11]} \
            ParameterKey=OpensearchVPCSG,ParameterValue=${vars[12]} \
            ParameterKey=OpensearchVPCSubnet,ParameterValue=${vars[13]} \
            ParameterKey=S3bucketName,ParameterValue=$LAMBDA_S3_BUCKET \
            ParameterKey=SchedulerExpression,ParameterValue=${vars[15]} \
            ParameterKey=SnapshotPrefix,ParameterValue=${vars[16]} \
            ParameterKey=SnapshotRepoName,ParameterValue=$SNAPSHOT_REPO_S3_BUCKET


# Use the below example  to help understand how to pass the parameters

# aws cloudformation create-stack \
# --stack-name MyStack2 \
# --template-body file://templates/resources.yml \
# --capabilities CAPABILITY_NAMED_IAM \
# --parameters ParameterKey=AOSSVersion,ParameterValue="OpenSearch_2.3" \
#             ParameterKey=AZCount,ParameterValue=2 \
#             ParameterKey=DataInstanceCount,ParameterValue=4 \
#             ParameterKey=DataInstanceType,ParameterValue="t3.medium.search" \
#             ParameterKey=LambdaFunctionName,ParameterValue="aoss-lambda-funvsix3" \
#             ParameterKey=LambdaIAMRole,ParameterValue="aoss-lambda-accessvsix3" \
#             ParameterKey=MasterInstanceCount,ParameterValue=3 \
#             ParameterKey=MasterInstanceType,ParameterValue="t3.medium.search" \
#             ParameterKey=MasterUName,ParameterValue="master" \
#             ParameterKey=MasterUPWD,ParameterValue="Test#12345" \
#             ParameterKey=OpensearchDomainName,ParameterValue="aoss-lambda-manual223" \
#             ParameterKey=OpensearchVPC,ParameterValue="vpc-0da915fcf039eb39c" \
#             ParameterKey=OpensearchVPCSG,ParameterValue="sg-011b56d327596819a" \
#             ParameterKey=OpensearchVPCSubnet,ParameterValue="subnet-07626552819c91b28\,subnet-0495c17bc63bd5e52\,subnet-08a16635aba92d42e" \
#             ParameterKey=S3bucketName,ParameterValue="lambda-artifacts-1ebfd1fa8ec3aa6d" \
#             ParameterKey=SchedulerExpression,ParameterValue="cron(59/59 16-18 * * ? *)" \
#             ParameterKey=SnapshotPrefix,ParameterValue="snapshot-" \
#             ParameterKey=SnapshotRepoName,ParameterValue="snapshot-repo-540ea26cc246d227"