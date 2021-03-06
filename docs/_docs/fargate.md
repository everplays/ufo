---
title: Fargate
---

Ufo supports Fargate.  AWS Fargate is a technology for Amazon ECS that allows you to run containers without having to manage servers or clusters.  This provides an interesting "serverless" option for running Docker containers on AWS.

Here's video demo of using ufo with ECS Fargate:

<div class="video-box"><div class="video-container">
<iframe src="https://www.youtube.com/embed/nYWt-mM7kyY" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
</div></div>

The commands from the video are also provided and explained below.

## Fargate Example

Here's an example of creating web service with Fargate.

    git clone https://github.com/tongueroo/demo-ufo demo
    cd demo
    ufo init --image tongueroo/demo-ufo --launch-type fargate --execution-role-arn arn:aws:iam::112233445566:role/ecsTaskExecutionRole
    ufo current --service demo-web
    ufo ship

**IMPORTANT**: Replace the `--execution-role-arn` with the ecsTaskExecutionRole associated with your account. If you do not have an ecsTaskExecutionRole yet, create one by following [Amazon ECS Task Execution IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html) guide.

You should see output similiar to this. Some output has been removed for conciseness.

    $ ufo ship
    Building docker image with:
      docker build -t tongueroo/demo-ufo:ufo-2018-06-29T22-54-07-20b3a10 -f Dockerfile .
    ...
    10:58:38PM CREATE_COMPLETE AWS::ECS::Service Ecs
    10:58:40PM CREATE_COMPLETE AWS::CloudFormation::Stack development-demo-web
    Stack success status: CREATE_COMPLETE
    Time took for stack deployment: 4m 24s.
    Software shipped!
    $

### Verification ufo commands

You can verify that service with these ufo commands.

    $ ufo ps
    => Service: demo-web
       Service name: development-demo-web-Ecs-1LMRH98Y352F7
       Status: ACTIVE
       Running count: 1
       Desired count: 1
       Launch type: FARGATE
       Task definition: demo-web:84
       Elb: develop-Elb-BNIP29PG593M-771779085.us-east-1.elb.amazonaws.com
    +----------+------+-------------+---------------+---------+-------+
    |    Id    | Name |   Release   |    Started    | Status  | Notes |
    +----------+------+-------------+---------------+---------+-------+
    | 78e02265 | web  | demo-web:84 | 2 minutes ago | RUNNING |       |
    +----------+------+-------------+---------------+---------+-------+
    $ ufo scale 2
    Scale demo-web service in development cluster to 2
    $ ufo ps --no-summary
    +----------+------+-------------+---------------+---------+-------+
    |    Id    | Name |   Release   |    Started    | Status  | Notes |
    +----------+------+-------------+---------------+---------+-------+
    | 78e02265 | web  | demo-web:84 | 2 minutes ago | RUNNING |       |
    +----------+------+-------------+---------------+---------+-------+
    $ ufo ps --no-summary
    +----------+------+-------------+---------------+---------+-------+
    |    Id    | Name |   Release   |    Started    | Status  | Notes |
    +----------+------+-------------+---------------+---------+-------+
    | 02b78575 | web  | demo-web:84 | PENDING       | PENDING |       |
    | 78e02265 | web  | demo-web:84 | 2 minutes ago | RUNNING |       |
    +----------+------+-------------+---------------+---------+-------+
    $ ufo ps --no-summary
    +----------+------+-------------+----------------+---------+-------+
    |    Id    | Name |   Release   |    Started     | Status  | Notes |
    +----------+------+-------------+----------------+---------+-------+
    | 02b78575 | web  | demo-web:84 | 12 seconds ago | RUNNING |       |
    | 78e02265 | web  | demo-web:84 | 3 minutes ago  | RUNNING |       |
    +----------+------+-------------+----------------+---------+-------+
    $

### Verification curl

You can verify that the app is up and running curling the ELB DNS.

    $ curl develop-Elb-BNIP29PG593M-771779085.us-east-1.elb.amazonaws.com ; echo
    42
    $

Congratulations 🎉 You have successfully deployed an docker web service to "serverless" Fargate.

## Clean up

Remove the service to save costs.

    $ ufo destroy
    You are about to destroy demo-web service on the development cluster.
    Are you sure you want to do this? (y/n) y
    Deleting CloudFormation stack with ECS resources: development-demo-web.
    11:05:40PM DELETE_IN_PROGRESS AWS::CloudFormation::Stack development-demo-web User
    ...
    11:07:51PM DELETE_COMPLETE AWS::EC2::SecurityGroup EcsSecurityGroup
    Stack development-demo-web deleted.
    $

Here's an article that compares the cost of ECS Fargate: [Heroku vs ECS Fargate vs EC2 On-Demand vs EC2 Spot Pricing Comparison](https://blog.boltops.com/2018/04/22/heroku-vs-ecs-fargate-vs-ec2-on-demand-vs-ec2-spot-pricing-comparison)


<a id="prev" class="btn btn-basic" href="{% link _docs/conventions.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-env.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
