Param ( [Parameter(Mandatory=$true)]$AddresseMac
)

#Formater l'adresse mac
$AddresseMac = $AddresseMac.ToLower()

$regex = "^([0-9A-F]{2}[-]){5}([0-9A-F]{2})$"

if ($AddresseMac -notmatch $regex) { 
    "L'adresse Mac doit etre de la forme XX-XX-XX-XX-XX-XX"
    Start-Sleep -Seconds 3
    break
    }


# verrification affichage du Lease
Get-DhcpServerv4Lease -ScopeId 172.21.0.0 -ClientId $AddresseMac

#demande de confirmation confirmation

$title = "Action:"
$message = "Voulez vous revoquer cette adresse Mac ?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes all the files in the folder."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Retains all the files in the folder."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 { break }
        1 { Write-Host "Ok, je touche a rien ! :)" ; Start-Sleep -Seconds 3 ; exit }
    }

#main

#recup du commentaire et affichage
$commentaire = Get-DhcpServerv4Filter -List Allow | Where-Object -Match -Property MacAddress -Value $AddresseMac | Format-Table -HideTableHeaders -Expand CoreOnly -Property Description | Out-String
$commentaire = $commentaire.Trim()

#1) passer du filtre Allow à Deny
#Write-Host "Bascule vers la liste Deny."
Remove-DhcpServerv4Filter -MacAddress $AddresseMac
Add-DhcpServerv4Filter -List Deny -Description $commentaire -MacAddress $AddresseMac  

clear

#2)supprimer la reservation d'adresse ip
Write-Host "1) Liberation de la réservation: ok"
remove-DhcpServerv4Reservation -ScopeId 172.21.0.0 -ClientId $AddresseMac

#3) resume

Write-Host "2) Nouvel etat:"
Get-DhcpServerv4Filter | Where-Object -Match -Property MacAddress -Value $AddresseMac

Start-Sleep -Seconds 5

#Remove-DhcpServerv4Filter -MacAddress d067e503c777
#Add-DhcpServerv4Filter -List Allow -Description "M08979 CRETINON Brice" -MacAddress d067e503c777
#Get-DhcpServerv4Filter | Where-Object -Match -Property MacAddress -Value d0-67-e5-03-c7-77

<#
    .SYNOPSIS
        Supprime une entrée dans le DHCP (libert la réservation et déplacement dans le filtre "Deny").
	.DESCRIPTION
		Permet la suppression d'une entrée dans le DHCP.
		2 actions: libert la réservation et déplace l'adresse Mac dans le filtre "Deny"
        Le script peut etre lancé directment sans rentrer de parametres.
    .PARAMETER AddresseMac
        Adresse MAC du poste avec obligatoirement les séparteur '-'.
		Exemple: 00-01-02-03-04-05
    .EXAMPLE
		SupprimePosteDHCP.ps1
		Puis entrer les paramtres AddresseMac
	.EXAMPLE
		SupprimePosteDHCP.ps1 -AddresseMac 00-01-02-03-04-05
	.NOTES
		Auteur:   BC
		Version:  1.0
#>
