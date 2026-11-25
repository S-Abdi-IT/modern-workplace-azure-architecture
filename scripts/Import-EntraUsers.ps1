Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"

$Gebruikers = Import-Csv -Path ".\gebruikers.csv"
$Domein = "://onmicrosoft.com"

foreach ($User in $Gebruikers) {
    $DisplayName = "$($User.Voornaam) $($User.Achternaam)"
    $UPN = "$($User.Voornaam.ToLower()).$($User.Achternaam.ToLower().Replace(' ', ''))@$Domein"
    
    $PasswordProfile = @{
        Password = "Welkom@2026!Nieuw"
        ForceChangePasswordNextSignIn = $true
    }

    New-MgUser -DisplayName $DisplayName `
        -UserPrincipalName $UPN `
        -MailNickname "$($User.Voornaam.ToLower())$($User.Achternaam.ToLower().Replace(' ', ''))" `
        -Department $User.Afdeling `
        -JobTitle $User.Functie `
        -AccountEnabled $true `
        -PasswordProfile $PasswordProfile

    Write-Host "Gebruiker aangemaakt: $DisplayName ($($User.Afdeling))" -ForegroundColor Green
}