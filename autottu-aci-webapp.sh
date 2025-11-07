###
### Script para criação do SQL Server, Database, Azure Container Instance (ACI) e Web App para o projeto AutoTTU
### Adaptado para CI/CD com Azure Pipelines
###
### Variáveis
###
grupoRecursos=rg-azuredevops-docker
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

# Variáveis do SQL Server
nomeServidor="autottu-sql"
nomeDatabase="AutoTTUDB"
# Altere para um usuário e senha seguros
sqlAdminUser="sqladmin"
sqlAdminPassword="SuaSenhaSegura123!"  # ALTERE ESTA SENHA!
# Tier do banco de dados (Basic, S0, S1, etc.)
databaseTier=Basic

###
### Criação do SQL Server e Database
###
echo "=========================================="
echo "Criando SQL Server e Database Azure..."
echo "=========================================="

# Verifica se o grupo de recursos existe
if [ $(az group exists --name $grupoRecursos) = false ]; then
    echo "Criando grupo de recursos $grupoRecursos..."
    az group create --name $grupoRecursos --location $regiao
    echo "Grupo de recursos $grupoRecursos criado"
fi

# Cria o SQL Server se não existir
if az sql server show --name $nomeServidor --resource-group $grupoRecursos &> /dev/null; then
    echo "SQL Server $nomeServidor já existe"
else
    echo "Criando SQL Server $nomeServidor..."
    az sql server create \
        --name $nomeServidor \
        --resource-group $grupoRecursos \
        --location $regiao \
        --admin-user $sqlAdminUser \
        --admin-password $sqlAdminPassword
    
    if [ $? -eq 0 ]; then
        echo "SQL Server $nomeServidor criado com sucesso"
    else
        echo "ERRO: Falha ao criar SQL Server"
        exit 1
    fi
fi

# Configura o firewall do SQL Server
echo "Configurando firewall do SQL Server..."

# Permite serviços do Azure (necessário para Azure Web App)
if az sql server firewall-rule show \
    --resource-group $grupoRecursos \
    --server $nomeServidor \
    --name AllowAzureServices &> /dev/null; then
    echo "Regra de firewall 'AllowAzureServices' já existe"
else
    az sql server firewall-rule create \
        --resource-group $grupoRecursos \
        --server $nomeServidor \
        --name AllowAzureServices \
        --start-ip-address 0.0.0.0 \
        --end-ip-address 0.0.0.0
    echo "Regra de firewall 'AllowAzureServices' criada"
fi

# Permite seu IP atual
MY_IP=$(curl -s https://api.ipify.org 2>/dev/null)
if [ ! -z "$MY_IP" ]; then
    if az sql server firewall-rule show \
        --resource-group $grupoRecursos \
        --server $nomeServidor \
        --name AllowMyIP &> /dev/null; then
        echo "Regra de firewall 'AllowMyIP' já existe"
    else
        az sql server firewall-rule create \
            --resource-group $grupoRecursos \
            --server $nomeServidor \
            --name AllowMyIP \
            --start-ip-address $MY_IP \
            --end-ip-address $MY_IP
        echo "Regra de firewall 'AllowMyIP' criada para IP: $MY_IP"
    fi
else
    echo "AVISO: Não foi possível detectar seu IP automaticamente"
fi

# Cria o banco de dados se não existir
if az sql db show --name $nomeDatabase --resource-group $grupoRecursos --server $nomeServidor &> /dev/null; then
    echo "Banco de dados $nomeDatabase já existe"
else
    echo "Criando banco de dados $nomeDatabase..."
    az sql db create \
        --resource-group $grupoRecursos \
        --server $nomeServidor \
        --name $nomeDatabase \
        --service-objective $databaseTier \
        --backup-storage-redundancy Local
    
    if [ $? -eq 0 ]; then
        echo "Banco de dados $nomeDatabase criado com sucesso"
    else
        echo "ERRO: Falha ao criar banco de dados"
        exit 1
    fi
fi

# Gera a connection string
connectionString="Server=tcp:$nomeServidor.database.windows.net,1433;Initial Catalog=$nomeDatabase;Persist Security Info=False;User ID=$sqlAdminUser;Password=$sqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

echo "SQL Server e Database configurados com sucesso!"
echo ""

###
### Verificação se a imagem existe no ACR
###
echo "=========================================="
echo "Verificando se a imagem existe no ACR..."
echo "=========================================="
# Verifica se o repositório existe
if az acr repository show --name $nomeACR --repository autottu &> /dev/null; then
    echo "Repositório 'autottu' encontrado no ACR"
    # Verifica se a tag 'latest' existe
    tags=$(az acr repository show-tags --name $nomeACR --repository autottu --query "[?name=='latest'].name" -o tsv)
    if [ ! -z "$tags" ] && echo "$tags" | grep -q "latest"; then
        echo "Tag 'latest' encontrada. Prosseguindo com criação do ACI..."
        createACI=true
    else
        echo "AVISO: Tag 'latest' não encontrada no repositório 'autottu'"
        echo "Execute o script 'build-and-push.sh' primeiro ou faça push da imagem manualmente"
        createACI=false
    fi
else
    echo "AVISO: Repositório 'autottu' não encontrado no ACR"
    echo "Execute o script 'build-and-push.sh' primeiro ou faça push da imagem manualmente"
    createACI=false
fi

###
### Criação do ACI (apenas se a imagem existir)
###
if [ "$createACI" = true ]; then
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
else
    echo "=========================================="
    echo "ACI não será criado. A imagem não existe no ACR."
    echo "=========================================="
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
    
    # Configura as credenciais do ACR no Web App (usando comandos atualizados)
    az webapp config container set \
        --name $appName \
        --resource-group $grupoRecursos \
        --container-image-name $imageACR \
        --container-registry-url https://$serverACR \
        --container-registry-user $userACR \
        --container-registry-password $passACR
    echo "Credenciais do ACR configuradas no Web App $appName"
fi

### Configura a porta e connection string do Serviço de Aplicativo
if az webapp show --name $appName --resource-group $grupoRecursos > /dev/null 2>&1; then
    # Configura a porta
    az webapp config appsettings set --resource-group $grupoRecursos --name $appName --settings WEBSITES_PORT=$port
    echo "Serviço de Aplicativo $appName configurado para escutar na porta $port com sucesso"
    
    # Configura a connection string do banco de dados
    az webapp config connection-string set \
        --resource-group $grupoRecursos \
        --name $appName \
        --connection-string-type SQLAzure \
        --settings DefaultConnection="$connectionString"
    echo "Connection string do banco de dados configurada no Web App $appName"
fi

echo "=========================================="
echo "Configuração concluída!"
echo "=========================================="
echo ""
echo "📊 SQL Server e Database:"
echo "   Server: $nomeServidor.database.windows.net"
echo "   Database: $nomeDatabase"
echo "   Usuário: $sqlAdminUser"
echo ""
if [ "$createACI" = true ]; then
    echo "🐳 Azure Container Instance:"
    echo "   URL: http://$nomeACI.$regiao.azurecontainer.io"
    echo ""
fi
echo "🌐 Azure Web App:"
echo "   URL: https://$appName.azurewebsites.net"
echo "   Connection String: Configurada automaticamente"
echo ""
echo "=========================================="
echo "IMPORTANTE:"
echo "1. A connection string do banco já foi configurada no Web App"
echo "2. Execute as migrations: dotnet ef database update"
echo "3. Configure ApiSettings__ApiKey no Web App se necessário"
echo ""
echo "Connection String para uso local (appsettings.json):"
echo "$connectionString"
echo "=========================================="
if [ "$createACI" = false ]; then
    echo ""
    echo "NOTA: Para criar o ACI, execute primeiro:"
    echo "  bash build-and-push.sh"
    echo "E depois execute este script novamente."
    echo "=========================================="
fi

