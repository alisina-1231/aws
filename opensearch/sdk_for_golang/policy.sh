aws iam create-policy \
  --policy-name OpenSearchDomainPolicy \
  --policy-document file://policy.json

aws iam attach-user-policy \
  --user-name admin1 \
  --policy-arn arn:aws:iam::832014379019:policy/OpenSearchDomainPolicy