# Imagem base
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Copiar arquivos de instalação do IIS
COPY iisinstall/ .

# Instalar IIS
RUN powershell.exe -Command `
    $ProgressPreference = 'SilentlyContinue'; `
    Install-WindowsFeature Web-Server; `
    Remove-Item -Recurse -Force iisinstall

# Copiar arquivos de configuração do IIS
COPY iisconfig/ C:/inetpub/wwwroot/

# Criar pool de aplicativos
RUN powershell.exe -Command `
    Import-Module WebAdministration; `
    New-Item 'IIS:\AppPools\MyAppPool' -ItemType ApplicationPool; `
    Set-ItemProperty 'IIS:\AppPools\MyAppPool' -Name 'processModel.identityType' -Value 'SpecificUser'; `
    Set-ItemProperty 'IIS:\AppPools\MyAppPool' -Name 'processModel.userName' -Value 'MyUserName'; `
    Set-ItemProperty 'IIS:\AppPools\MyAppPool' -Name 'processModel.password' -Value 'MyPassword'

# Criar aplicativo no Default Web Site
RUN powershell.exe -Command `
    Import-Module WebAdministration; `
    New-WebApplication -Site 'Default Web Site' -Name 'MyApp' -PhysicalPath 'C:\inetpub\wwwroot\MyApp' -ApplicationPool 'MyAppPool'

# Abrir porta 80 para tráfego HTTP
EXPOSE 80

# Definir diretório de trabalho padrão
WORKDIR C:/inetpub/wwwroot

# Comando padrão para execução do contêiner
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
