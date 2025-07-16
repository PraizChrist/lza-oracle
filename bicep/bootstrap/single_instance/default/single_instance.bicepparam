using '../../main.bicep'

param resourceGroupName = 'oracletest'

param location = 'eastus'

param virtualNetworks = [
  {
    virtualNetworkName: 'vnet1'
    addressPrefixes: [
      '10.0.0.0/16' ]
    subnetName: 'subnet1'
    addressPrefix: '10.0.0.0/24'
  } ]

param networkSecurityGroups = [
  {
    networkSecurityGroupName: 'ora01nsg'
    securityRules: []
  }
]

param virtualMachines = [
  {
    virtualMachineName: 'ora01'
    vmSize: 'Standard_D4s_v5'
    avZone: 1
    adminUsername: 'oracle'
    managedIdentities: {
      userAssignedResourceIds: [
        '<userAssignedId>'
      ]
    }
    sshPublicKey: '<sshKey>'
    dataDisks: [
      {
        caching: 'None'
        writeAcceleratorEnabled: false
        diskSizeGB: '1024'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      {
        caching: 'None'
        diskSizeGB: '1024'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      {
        name: 'redo'
        caching: 'ReadOnly'
        writeAcceleratorEnabled: false
        diskSizeGB: '1024'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    ]
  }
]

param tags = {
  environment: 'dev'
  costCenter: 'it'
}

param oracleImageReference = {
  publisher: 'oracle'
  offer: 'oracle-database-19-3'
  sku: 'oracle-database-19-0904'
  version: 'latest'
}

param enableTelemetry = true
param telemetryPid = '5cb0073e-724a-428b-a5ba-1a6d3343effb'
