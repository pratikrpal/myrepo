
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
import json

def get_virtual_machine_metadata(subscription_id, resource_group_name, virtual_machine_name):
    # Initialize Azure credentials
    credentials = DefaultAzureCredential()

    # Initialize Compute Management Client
    compute_client = ComputeManagementClient(credentials, subscription_id)

    # Get the instance details
    vm_instance = compute_client.virtual_machines.get(resource_group_name, virtual_machine_name)
    
    # Extract relevant metadata
    metadata = {
        "id": vm_instance.id,
        "name": vm_instance.name,
        "location": vm_instance.location,
        "tags": vm_instance.tags,
        "type": vm_instance.type,
        "properties": {
            "hardware_profile": {
                "vm_size": vm_instance.hardware_profile.vm_size
            },  
            "os_profile": {
                "computer_name": vm_instance.os_profile.computer_name,
                "admin_username": vm_instance.os_profile.admin_username,
                # Add more properties as needed
            },
            "network_profile": {
                "network_interfaces": [{
                    "id": nic.id,
                } for nic in vm_instance.network_profile.network_interfaces]
            }
        }
    }

    # Serialize metadata to JSON format
    metadata_json = json.dumps(metadata, indent=4)
    return metadata_json

# Example usage
subscription_id = "3942318c-6500-4a79-990b-bccf213f2640"
resource_group_name = "test-rg"
virtual_machine_name = "test-vm"

metadata = get_virtual_machine_metadata(subscription_id, resource_group_name, virtual_machine_name)
print(metadata)