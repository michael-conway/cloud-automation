rolename="default-vpc-gen3--default--gitops"
description="Role created with gen3 awsrole"
path="/gen3_service/"
ar_policy=<<EDOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::784855359364:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/BC516225886DC7FF87B81A61A9F2908D"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-east-1.amazonaws.com/id/BC516225886DC7FF87B81A61A9F2908D:aud": "sts.amazonaws.com",
          "oidc.eks.us-east-1.amazonaws.com/id/BC516225886DC7FF87B81A61A9F2908D:sub": "system:serviceaccount:default:gitops-sa"
        }
      }
    }
  ]
}
EDOC
