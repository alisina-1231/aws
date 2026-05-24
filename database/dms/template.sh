aws cloudformation create-stack \
  --stack-name dms-postgres-to-mysql \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
    ParameterKey=VpcId,ParameterValue=vpc-xxxxxxxx \
    ParameterKey=PublicSubnetId,ParameterValue=subnet-xxxxxxxx \
    ParameterKey=PostgresEndpoint,ParameterValue=my-postgres.xxxxx.us-east-1.rds.amazonaws.com \
    ParameterKey=PostgresUsername,ParameterValue=admin \
    ParameterKey=PostgresPassword,ParameterValue=YourStrongPassword123! \
    ParameterKey=PostgresDatabase,ParameterValue=postgres \
    ParameterKey=MysqlEndpoint,ParameterValue=my-mysql.xxxxx.us-east-1.rds.amazonaws.com \
    ParameterKey=MysqlUsername,ParameterValue=admin \
    ParameterKey=MysqlPassword,ParameterValue=YourStrongPassword123! \
    ParameterKey=MysqlDatabase,ParameterValue=mysql