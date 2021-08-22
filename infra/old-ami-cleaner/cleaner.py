import os
import boto3
import dateutil.parser

client = boto3.client('ec2')


def remove_image(image):
    snapshots = list(map(lambda m: m['Ebs']['SnapshotId'], image['BlockDeviceMappings']))
    client.deregister_image(
        ImageId=image['ImageId']
    )
    for snapshot in snapshots:
        client.delete_snapshot(
            SnapshotId=snapshot
        )


def handler(event, context):
    retain = int(os.environ['RETAIN'])
    tag = os.environ['IMAGE_NAME_TAG']
    response = client.describe_images(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [tag]
            }
        ]
    )
    images = response['Images']
    print("Found {} images with Name {}".format(len(images), tag))
    images.sort(reverse=True, key=lambda image: dateutil.parser.isoparse(image['CreationDate']))
    old_images = images[retain:]
    num_to_remove = len(old_images)
    if num_to_remove > 0:
        print("Trying to remove {} images".format(len(old_images)))
        for image in old_images:
            remove_image(image)
    else:
        print("No old images to remove")
    return "OK"
