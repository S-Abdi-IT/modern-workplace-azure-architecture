@description('Locatie voor alle resources')
param location string = resourceGroup().location

@description('Gebruikersnaam voor de lokale Windows Server beheerder')
param adminUsername string = 'serveradmin'

@secure()
@description('Wachtwoord voor de lokale Windows Server beheerder')
param adminPassword string

var vnetName = 'Kantoor-VNet'
var vmName = 'Bedrijfs-Server-01'
var nicName = '${vmName}-nic'
var bastionName = 'Kantoor-Bastion'
var bastionPublicIpName = 'Kantoor-Bastion-pip'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'Server-Subnet'
        properties: { addressPrefix: '10.0.1.0/24' }
      }
      {
        name: 'AzureBastionSubnet'
        properties: { addressPrefix: '10.0.2.0/26' }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: { id: vnet.properties.subnets.id }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_DS1_v2' }
    osProfile: {
      computerName: 'BedrijfsSrv01'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
    }
    networkProfile: {
      networkInterfaces: [{ id: nic.id }]
    }
  }
}

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: bastionPublicIpName
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: bastionName
  location: location
  sku: { name: 'Basic' }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: { id: vnet.properties.subnets.id }
          publicIPAddress: { id: bastionPublicIp.id }
        }
      }
    ]
  }
}
