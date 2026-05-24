aws cloudformation create-stack \
--stack-name datasync-lab \
--template-body file://template.yaml \
--capabilities CAPABILITY_NAMED_IAM


aws datasync list-tasks

aws datasync start-task-execution \
--task-arn "arn:aws:datasync:us-east-1:832014379019:task/task-06df47c23fe8e7e0b"

aws datasync list-task-executions \
--task-arn "arn:aws:datasync:us-east-1:832014379019:task/task-06df47c23fe8e7e0b"

aws cloudformation delete-stack \
--stack-name datasync-lab