Param ( [Parameter(Mandatory=$true)]$AddresseMac
)

Get-DhcpServerv4Lease -ScopeId 172.21.0.0 -ClientId $AddresseMac

#passer du filtre Allow à Deny

comment = Get-DhcpServerv4Filter -List Allow | Where-Object MacAddress -EQ $AddresseMac | Format-List -Property Description

Remove-DhcpServerv4Filter -MacAddress $AddresseMac
Add-DhcpServerv4Filter -MacAddress $AddresseMac -List Deny -Description $comment

#supprimer la reservation d'adresse ip
Remove-DhcpServerv4Reservation -ClientId $AddresseMac
