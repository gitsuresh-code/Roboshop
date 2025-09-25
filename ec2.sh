#!/bin/bash

ami="ami-09c813fb71547fc4f"
sg="sg-0bdcda12513912f85" # replace with your SG ID
hostedzone="Z04272802545XSOGBRNOM" # replace with your ID
dns="sureshdevops.fun"

for instance in $@ # mongodb redis mysql
do
    instance_id=$(aws ec2 run-instances --image-id $ami --instance-type t3.micro --security-group-ids $sg --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    # Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$dns" # mongodb.daws86s.fun
    else
        IP=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$dns" # daws86s.fun
    fi

    echo "$instance: $IP"

   aws route53 change-resource-record-sets \
    --hosted-zone-id $hostedzone \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '

done