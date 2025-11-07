###
### Script para criação do Azure Container Instance (ACI) e Web App para o projeto AutoTTU
### Adaptado para CI/CD com Azure Pipelines
###
### Variáveis
###
grupoRecursos=rg-azuredevops-docker
# Altere para seu RM
nomeACR="autottu"
imageACR="autottu.azurecr.io/autottu:latest"
serverACR="autottu.azurecr.io"
userACR=$(az acr credential show --name $nomeACR --query "username" -o tsv)
passACR=$(az acr credential show --name $nomeACR --query "passwords[0].value" -o tsv)
nomeACI="autottu"
regiao=brazilsouth
planService=planAutoTTUWebApp
sku=F1
appName="autottuwebapp"
port=80

###
### Criação do ACI
###
echo "=========================================="
echo "Criando Azure Container Instance..."
echo "=========================================="
az container create \
    --resource-group $grupoRecursos \
    --name $nomeACI \
    --image $imageACR \
    --cpu 1 \
    --memory 1 \
    --os-type Linux \
    --registry-login-server $serverACR \
    --registry-username $userACR \
    --registry-password $passACR \
    --dns-name-label $nomeACI \
    --restart-policy Always \
    --ports 80

if [ $? -eq 0 ]; then
    echo "Azure Container Instance $nomeACI criado com sucesso"
    echo "URL: http://$nomeACI.$regiao.azurecontainer.io"
else
    echo "Erro ao criar Azure Container Instance"
fi

###
### Criação do Web App
###
echo "=========================================="
echo "Criando Azure Web App..."
echo "=========================================="

### Cria o Plano de Serviço se não existir
if az appservice plan show --name $planService --resource-group $grupoRecursos &> /dev/null; then
    echo "O plano de serviço $planService já existe"
else
    az appservice plan create --name $planService --resource-group $grupoRecursos --is-linux --sku $sku
    echo "Plano de serviço $planService criado com sucesso"
fi 

### Cria o Serviço de Aplicativo se não existir
if az webapp show --name $appName --resource-group $grupoRecursos &> /dev/null; then
    echo "O Serviço de Aplicativo $appName já existe"
else
    az webapp create --resource-group $grupoRecursos --plan $planService --name $appName --deployment-container-image-name $imageACR
    echo "Serviço de Aplicativo $appName criado com sucesso"
    
    # Configura as credenciais do ACR no Web App
    az webapp config container set \
        --name $appName \
        --resource-group $grupoRecursos \
        --docker-custom-image-name $imageACR \
        --docker-registry-server-url https://$serverACR \
        --docker-registry-server-user $userACR \
        --docker-registry-server-password $passACR
    echo "Credenciais do ACR configuradas no Web App $appName"
fi

### Configura a porta do Serviço de Aplicativo
if az webapp show --name $appName --resource-group $grupoRecursos > /dev/null 2>&1; then
    az webapp config appsettings set --resource-group $grupoRecursos --name $appName --settings WEBSITES_PORT=$port
    echo "Serviço de Aplicativo $appName configurado para escutar na porta $port com sucesso"
fi

echo "=========================================="
echo "Configuração concluída!"
echo "=========================================="
echo "ACI URL: http://$nomeACI.$regiao.azurecontainer.io"
echo "Web App URL: https://$appName.azurewebsites.net"
echo "=========================================="
echo "IMPORTANTE: Configure as variáveis de ambiente no Azure Web App:"
echo "- ConnectionStrings__DefaultConnection (SQL Server Azure)"
echo "- ApiSettings__ApiKey (se necessário)"
echo "=========================================="

