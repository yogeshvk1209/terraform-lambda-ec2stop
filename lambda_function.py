import boto3

def lambda_handler(event, context):
    client = boto3.client('ec2')
    ec2_regions = [region['RegionName'] for region in client.describe_regions()['Regions']]
    print(ec2_regions)
    for region in ec2_regions:
        print(region)
        ec2 = boto3.resource('ec2',region_name=region)
        # Filter out All running instances
        running_filters = [
            {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        all_instances = ec2.instances.filter(Filters=running_filters)
        
        # Filter out tagged instanes
        tagged_filters = [
            {'Name': 'instance-state-name', 'Values': ['running']},
            {'Name': 'tag:AutoOff', 'Values': ['False']}
            ]
        tagged_instances = ec2.instances.filter(Filters=tagged_filters)
        
        # Select only running instances which are not in tagged instances list
        instances_to_shutdown = [delete.id for delete in all_instances if delete.id not in [tagged.id for tagged in tagged_instances]]
        if len(instances_to_shutdown) > 0:
            # perform the shutdown
            print(instances_to_shutdown)
            shutting_down = ec2.instances.filter(InstanceIds=instances_to_shutdown).stop()
            print(shutting_down)
        else:
            print("Nothing to shutdown")
