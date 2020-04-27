import boto3

def lambda_handler(event, context):
    client = boto3.client('ec2')
    ec2_regions = [region['RegionName'] for region in client.describe_regions()['Regions']]
    for region in ec2_regions:
        ec2 = boto3.resource('ec2',region_name=region)
        filters = [
            {'Name': 'tag:AutoOff', 'Values': ['True']},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
        instances = ec2.instances.filter(Filters=filters)
        RunningInstances = [instance.id for instance in instances]
        if len(RunningInstances) > 0:
            #perform the shutdown
            shuttingDown = ec2.instances.filter(InstanceIds=RunningInstances).stop()
            print(shuttingDown)
        else:
            print("Nothing to shutdown")
